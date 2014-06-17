package main
///////////////////////////////////
// FALTA ACABAR DE PERFILAR 
///////////////////////////////////
import (
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net"
	"time"
	"os"
)

type Mood struct {
	XMLName xml.Name `xml:"mood"`
	Happy   float32  `xml:"happy,attr"`
	Sad     float32  `xml:"sad,attr"`
	Angry   float32  `xml:"angry,attr"`
	Relax   float32  `xml:"relaxed,attr"`
	Arousal float32  `xml:"arousal,attr"`
	Balence float32  `xml:"valence,attr"`
	HBR     float32  `xml:"hbr,attr"`
	ECG     float32  `xml:"ecg,attr"`
	// Results bool     `xml:"results,attr"`
}

type MoodResponse struct {
	command string
	param   string
}

func handleConnection(conn net.Conn) {
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
			
			fmt.Println("COMMAND :", string(reply[0:n]))

			p := &Mood{}
			// p.Relax = rand.Float32()
			// p.Angry = rand.Float32()
			// p.Happy = rand.Float32()*100
			// p.Sad = rand.Float32()
			p.Relax = .3
			p.Angry = .7
			p.Happy = .9
			p.Sad = .4
			p.Arousal = rand.Float32()
			p.Balence = rand.Float32()
			p.ECG = rand.Float32()
			p.HBR = 50 + rand.Float32()*10
			// p.results = false;

			xml_response, _ := xml.MarshalIndent(p, "", "   ")
			conn.Write([]byte(xml_response))

			fmt.Println("Server Handle Done : ", p)
		}
		if string(reply[0:n]) == "exit" {
			
			fmt.Println("COMMAND :", string(reply[0:n]))

			os.Exit(0)
			// falta tancar conexions !
		}
	}

}

func main() {
	// Random seed number
	rand.Seed(42)

	// Listen on TCP port 8080 on all interfaces.
	l, err := net.Listen("tcp", ":8080")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("enobio2Moon Server Socket Ready")

	defer l.Close()
	for {
		// Wait for a connection.
		conn, err := l.Accept()
		if err != nil {
			log.Fatal(err)
		}
		// Handle the connection in a new goroutine.
		// The loop then returns to accepting, so that
		// multiple connections may be served concurrently.

		go handleConnection(conn)
	}
}
