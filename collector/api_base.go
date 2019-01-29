package collector

import (
	"encoding/json"
	"net/http"

	"github.com/prometheus/common/log"
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
		log.Errorf("Cannot retrieve metrics: %v", err)
		return err
	}

	defer func() {
		if err := response.Body.Close(); err != nil {
			log.Errorf("Cannot close response body: %v", err)
		}
	}()

	err = json.NewDecoder(response.Body).Decode(target)
	if err != nil {
		log.Errorf("Cannot parse Logstash response json: %v", err)
	}

	return err
}
