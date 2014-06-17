// MoonClient

// http://en.wikipedia.org/wiki/Double-precision_floating-point_format
// 3ff0 0000 0000 0000 (16)   = 1
// 3ff0 0000 0000 0001 (16)   ≈ 1.0000000000000002, the smallest number > 1
// 3ff0 0000 0000 0002 (16)   ≈ 1.0000000000000004
// 4000 0000 0000 0000 (16)   = 2
// c000 0000 0000 0000 (16)   = –2
// 8000 0000 0000 0000 (16)   = –0

package main

import (
	"bufio"
	"bytes"
	"eegMood/enobioDSP"
	"encoding/binary"
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"math"
	"math/rand"
	"net"
	"os"
	"time"
)

// Intermediate from OpenViBE inputs
type avState struct {
	Aurosal float64
	Valence float64
}

// Intermediate Float64
type MoodState struct {
	H, S, A, R       float64
	Arousal, Valance float64
	HBR              float64
	ECG              float64
	theta            float64
}

// XML to Processing
type MoodXML struct {
	XMLName xml.Name `xml:"mood"`
	Happy   float32  `xml:"happy,attr"`
	Sad     float32  `xml:"sad,attr"`
	Angry   float32  `xml:"angry,attr"`
	Relax   float32  `xml:"relaxed,attr"`
	Arousal float32  `xml:"arousal,attr"`
	Valence float32  `xml:"valence,attr"`
	HBR     float32  `xml:"hbr,attr"`
	ECG     float32  `xml:"ecg,attr"`
}

//type MoodResponse struct {
//	command string
//	param   string
//}

// Module variables
var moodShortTime avState
var moodLongTime avState
var mood MoodState

var bpf enobioDSP.FIR
var moodArousalCapture enobioDSP.Capture
var moodValanceCapture enobioDSP.Capture

// Split function

// Create a custom split function by wrapping the existing ScanLines function.
// OpenViBE terminated line = 8000 0000 0000 0000 (16) = –0
func splitOpenViBE(data []byte) (token [][]byte) {
	// OpenViBE terminated line = 8000 0000 0000 0000 (16) = –0
	// Socket receive 0000 0000 0000 0080 LSF firts in time
	openViBEEOF := []byte{0, 0, 0, 0, 0, 0, 0, 0x80}

	// Split
	token = bytes.Split(data, openViBEEOF)
	return
}

//func openViBEAurosal(fileName string, stream chan []byte) (cAurosal chan MoodState) {
func openViBEAurosal(fileName string, mood *avState, stream chan []byte) {

	// Create a file where store incomming streaming
	fOut, _ := os.Create(fileName)

	// open file as write-only
	// seek access relative to the origen of the file
	fOut, _ = os.OpenFile(fileName, os.O_WRONLY, 0666)

	// defer help close at the end
	defer fOut.Close()

	// buffered writer, provide the interface with the file
	w := bufio.NewWriter(fOut)

	//var mood MoodState

	for {
		// Wait incomming stream
		buffer := <-stream

		// Split incomming stream
		arousals := splitOpenViBE(buffer)

		for _, aurosal := range arousals {
			if len(aurosal) > 15 {

				buf := bytes.NewReader(aurosal)
				err := binary.Read(buf, binary.LittleEndian, mood)
				if err != nil {
					fmt.Println("binary.Read failed:", err)
				}

				//fmt.Println(i, aurosal)
				//fmt.Println(i, mood)
			}
		}

		// Make a copy of the incomming stream
		_, err := w.Write(buffer)
		if err != nil {
			log.Fatal("Copy Buffer error: ", err)
		}
		w.Flush()
	}
	return
}

func quadrant(moodShortTime, moodLongTime avState) (mood MoodState) {

	//mood.Arousal = mood.Arousal + 0.025*(moodShortTime.Aurosal-moodLongTime.Aurosal)
	//mood.Valance = mood.Valance + 0.025*(moodShortTime.Valence-moodLongTime.Valence)
	valance := (moodShortTime.Valence - moodLongTime.Valence)
	arousal := (moodShortTime.Aurosal - moodLongTime.Aurosal)

	// Band Pass Filter
	enobioDSP.MoodAppend(&moodValanceCapture, valance)
	mood.Valance = enobioDSP.MoodNormSample(&moodValanceCapture)

	// Band Pass Filter
	enobioDSP.MoodAppend(&moodArousalCapture, arousal)
	mood.Arousal = enobioDSP.MoodNormSample(&moodArousalCapture)

	if mood.Valance != 0 {
		tag := mood.Arousal / mood.Valance
		mood.theta = math.Atan(tag)

	} else {
		mood.theta = 0
	}
	theta := mood.theta

	// select the Quadrant
	Q := 0
	if mood.Valance > 0 {
		if mood.Arousal > 0 {
			Q = 1
		} else {
			Q = 4
		}
	} else {
		if mood.Arousal > 0 {
			Q = 2
		} else {
			Q = 3
		}
	}

	// Mood coefficients
	switch Q {
	case 1:
		mood.H = 1
		mood.A = math.Sin(theta)
		mood.R = math.Cos(theta)
		mood.S = 0
	case 2:
		mood.H = math.Sin(theta)
		mood.A = 1
		mood.R = 0
		mood.S = math.Cos(theta)
	case 3:
		mood.H = 0
		mood.A = math.Cos(theta)
		mood.R = math.Sin(theta)
		mood.S = 1
	case 4:
		mood.H = math.Cos(theta)
		mood.A = 0
		mood.R = 1
		mood.S = math.Sin(theta)
	default:
		mood.H = 0
		mood.A = 0
		mood.R = 0
		mood.S = 0
	}
	return
}

func handleConnection(conn net.Conn, mood *MoodState) {
	// TCP buffer size
	reply := make([]byte, 1024)

	// defer, close the socket when the ERROR
	defer conn.Close()

	// loop
	for {
		n, err := conn.Read(reply)
		if err != nil {
			// if not active wait 0.1 second
			if err == io.EOF {
				time.Sleep(100 * time.Millisecond)
			} else {
				//log.Fatal(err)
				fmt.Println("Error Recv : ")
				return
			}
		}
		if string(reply[0:n]) == "mood" {

			fmt.Println("\nCOMMAND :", string(reply[0:n]))

			p := &MoodXML{}

			p.Relax = float32(mood.R)
			p.Angry = float32(mood.A)
			p.Happy = float32(mood.H)
			p.Sad = float32(mood.S)
			p.Arousal = float32(mood.Arousal)
			p.Valence = float32(mood.Valance)

			p.ECG = rand.Float32()
			p.HBR = 50 + rand.Float32()*10

			//fmt.Println("Server Mood : ", mood)

			xml_response, _ := xml.MarshalIndent(p, "", "   ")
			conn.Write([]byte(xml_response))

			//fmt.Println("Server Handle Done : ", p)
		}
		if string(reply[0:n]) == "exit" {

			fmt.Println("\nCOMMAND :", string(reply[0:n]))

			os.Exit(0)
			// falta tancar conexions !
		}
	}

}

// main
func main() {
	var chnShortTime chan []byte = make(chan []byte)
	var chnLongTime chan []byte = make(chan []byte)

	enobioDSP.MoodSetFilters()
	moodArousalCapture.Amplitude = make([]float64, len(enobioDSP.MoodStandarizationFilter.Weights))
	moodValanceCapture.Amplitude = make([]float64, len(enobioDSP.MoodStandarizationFilter.Weights))

	// Buffer, asynchronous transfers
	buffer := make([]byte, 3*64) //OpenViBe float64 S,S,EOL

	// time stamp
	t := time.Now()
	//
	fileShortTime := t.Format("20060102150405") + "Short.bit"
	fileLongTime := t.Format("20060102150405") + "Long.bit"

	fmt.Println("Start Short client")
	connShortTime, err := net.Dial("tcp", "localhost:5679")
	if err != nil {
		log.Fatal("Short Time Client Connection error", err)
	}

	fmt.Println("Start Long client")
	connLongTime, err := net.Dial("tcp", "localhost:5678")
	if err != nil {
		log.Fatal("Long Time Client Connection error", err)
	}

	// Listen on TCP port 8080 on all interfaces.
	GUI, err := net.Listen("tcp", ":8080")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("enobio2Moon Server Socket Ready")

	// Wait for a connection.
	conn, err := GUI.Accept()
	if err != nil {
		log.Fatal(err)
	}
	// Handle the connection in a new goroutine.
	// The loop then returns to accepting, so that
	// multiple connections may be served concurrently.

	// Goroutine to handle Aurosal streaming
	go openViBEAurosal(fileShortTime, &moodShortTime, chnShortTime)
	go openViBEAurosal(fileLongTime, &moodLongTime, chnLongTime)

	defer GUI.Close()
	for {
		go handleConnection(conn, &mood)
		// Read incomming Short Time stream
		i, err := connShortTime.Read(buffer)
		if err != nil {
			log.Fatal("Read Buffer error", err)
		}

		// stream new values
		chnShortTime <- buffer[0:i]

		// Read incomming Long Time stream
		i, err = connLongTime.Read(buffer)
		if err != nil {
			log.Fatal("Read Buffer error", err)
		}

		// stream new values
		chnLongTime <- buffer[0:i]

		// Report results
		fmt.Println("AV Short ", i, moodShortTime)
		fmt.Println("AV Long ", i, moodLongTime)

		// Build mood to report
		mood = quadrant(moodShortTime, moodLongTime)
		fmt.Printf("\nMood A=%[1]v V=%[2]v theta=%[3]v ", mood.Arousal, mood.Valance, mood.theta)
		fmt.Printf("\nMood Max A=%[1]v V=%[2]v", moodArousalCapture.R, moodValanceCapture.R)
		fmt.Printf("\nMood last sample A=%[1]v V=%[2]v", moodArousalCapture.Sample, moodValanceCapture.Sample)
		//fmt.Printf("\nMood A=%[1]v", moodArousalCapture.Amplitude)

	}

	fmt.Println("Done")

}
