# macros
John Endres' (Macplugins) macro collection.

Macros defined:

1. **buildURLRequest** -- Builds an URLRequest based on a string-based url.
2. **OSLogger** -- Adds a logger instance to a class or a struct.  Shows how to add a member to a class or a struct

# **Usage**


## buildURLRequest
### Create a GET request with no headers

    if let request = #buildURLRequest("https://www.google.com") {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

### Create a PUT request with no headers

    if let request = #buildURLRequest("https://www.apple.com", method: "PUT") {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

### Create a POST request with headers

    if let request = #buildURLRequest("https://www.macplugins.com", method: "POST", headers: ["one":"two", "three":"four"]) {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

## OSLogger

This shows a struct with three loggers attached that show some of the ways to use it.  All of the parameters are not required.  The methods defined in this struct are using the loggers
that were added by the 3 attached macros.

	@OSLogger
	@OSLogger("otherLogger", category: "Other")
	@OSLogger("fullLogger", subsystem: "Example sub-system", category: "example category")
	struct ExampleStruct {
	    func example() {
	        logger.debug("a debug message")
	    }
	    
	    func other() {
	        otherLogger.debug("other debug message")
	    }
	    
	    func exampleWithMore(_ more: String) {
	        logger.info("a debug message \(more, privacy: .private)")
	    }
	    
	    func fullExample() {
	        fullLogger.notice("Message from fullLogger")
	    }
	}

