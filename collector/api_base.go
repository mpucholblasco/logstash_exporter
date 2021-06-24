package collector

import (
	"encoding/json"
	"log"
	"net/http"
)

// HTTPHandler type
type HTTPHandler struct {
	Endpoint string
}

// Get method for HTTPHandler
func (h *HTTPHandler) Get() (http.Response, error) {
	response, err := http.Get(h.Endpoint)
	if err != nil {
		return http.Response{}, err
	}

	return *response, nil
}

// HTTPHandlerInterface interface
type HTTPHandlerInterface interface {
	Get() (http.Response, error)
}

func getMetrics(h HTTPHandlerInterface, target interface{}) error {
	response, err := h.Get()
	if err != nil {
		log.Printf("[ERROR] Cannot retrieve metrics: %v\n", err)
		return err
	}

	defer func() {
		if err := response.Body.Close(); err != nil {
			log.Printf("[ERROR] Cannot close response body: %v\n", err)
		}
	}()

	err = json.NewDecoder(response.Body).Decode(target)
	if err != nil {
		log.Printf("[ERROR] Cannot parse Logstash response json: %v\n", err)
	}

	return err
}
