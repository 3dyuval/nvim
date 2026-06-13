;; blink.cmp source for curl flags, HTTP methods, and common headers
;; Activates when the current line contains "curl"

(local flags
  [{:label "-X" :detail "Specify request method" :insertText "-X "}
   {:label "-H" :detail "Add header" :insertText "-H \"\"" :insertTextFormat 2}
   {:label "-d" :detail "Send data" :insertText "-d "}
   {:label "-o" :detail "Write output to file" :insertText "-o "}
   {:label "-O" :detail "Save with remote filename"}
   {:label "-L" :detail "Follow redirects"}
   {:label "-s" :detail "Silent mode"}
   {:label "-S" :detail "Show errors in silent mode"}
   {:label "-v" :detail "Verbose output"}
   {:label "-k" :detail "Allow insecure connections"}
   {:label "-i" :detail "Include response headers"}
   {:label "-I" :detail "HEAD request (headers only)"}
   {:label "-u" :detail "User:password" :insertText "-u "}
   {:label "-b" :detail "Send cookies" :insertText "-b "}
   {:label "-c" :detail "Save cookies to file" :insertText "-c "}
   {:label "-F" :detail "Multipart form data" :insertText "-F "}
   {:label "-w" :detail "Write out format" :insertText "-w "}
   {:label "-m" :detail "Max time (seconds)" :insertText "-m "}
   {:label "--connect-timeout" :detail "Connection timeout (seconds)" :insertText "--connect-timeout "}
   {:label "--retry" :detail "Retry count" :insertText "--retry "}
   {:label "--retry-delay" :detail "Delay between retries" :insertText "--retry-delay "}
   {:label "--compressed" :detail "Request compressed response"}
   {:label "--data-raw" :detail "Send raw data" :insertText "--data-raw "}
   {:label "--data-binary" :detail "Send binary data" :insertText "--data-binary "}
   {:label "--data-urlencode" :detail "URL-encode data" :insertText "--data-urlencode "}
   {:label "--header" :detail "Add header (long form)" :insertText "--header \"\"" :insertTextFormat 2}
   {:label "--request" :detail "Specify method (long form)" :insertText "--request "}
   {:label "--output" :detail "Write to file (long form)" :insertText "--output "}
   {:label "--location" :detail "Follow redirects (long form)"}
   {:label "--silent" :detail "Silent mode (long form)"}
   {:label "--verbose" :detail "Verbose (long form)"}
   {:label "--insecure" :detail "Skip TLS verification"}
   {:label "--cert" :detail "Client certificate" :insertText "--cert "}
   {:label "--key" :detail "Private key" :insertText "--key "}
   {:label "--cacert" :detail "CA certificate" :insertText "--cacert "}
   {:label "--proxy" :detail "Use proxy" :insertText "--proxy "}
   {:label "--max-redirs" :detail "Max redirects" :insertText "--max-redirs "}
   {:label "--fail" :detail "Fail silently on HTTP errors"}
   {:label "--fail-with-body" :detail "Fail but still output body"}
   {:label "--json" :detail "Shorthand for JSON POST" :insertText "--json "}
   {:label "--url" :detail "Explicit URL" :insertText "--url "}
   {:label "--tcp-fastopen" :detail "Use TCP Fast Open"}
   {:label "--http2" :detail "Use HTTP/2"}
   {:label "--http3" :detail "Use HTTP/3"}
   {:label "--tlsv1.2" :detail "Use TLS 1.2"}
   {:label "--tlsv1.3" :detail "Use TLS 1.3"}])

(local methods
  [{:label "GET" :detail "HTTP GET"}
   {:label "POST" :detail "HTTP POST"}
   {:label "PUT" :detail "HTTP PUT"}
   {:label "PATCH" :detail "HTTP PATCH"}
   {:label "DELETE" :detail "HTTP DELETE"}
   {:label "HEAD" :detail "HTTP HEAD"}
   {:label "OPTIONS" :detail "HTTP OPTIONS"}])

(local headers
  [{:label "Content-Type: application/json" :detail "JSON content type"}
   {:label "Content-Type: application/x-www-form-urlencoded" :detail "Form content type"}
   {:label "Content-Type: multipart/form-data" :detail "Multipart content type"}
   {:label "Content-Type: text/plain" :detail "Plain text content type"}
   {:label "Content-Type: text/html" :detail "HTML content type"}
   {:label "Content-Type: application/xml" :detail "XML content type"}
   {:label "Accept: application/json" :detail "Accept JSON"}
   {:label "Accept: text/html" :detail "Accept HTML"}
   {:label "Accept: */*" :detail "Accept anything"}
   {:label "Authorization: Bearer " :detail "Bearer token auth"}
   {:label "Authorization: Basic " :detail "Basic auth"}
   {:label "Cache-Control: no-cache" :detail "No cache"}
   {:label "Cache-Control: max-age=" :detail "Cache max age"}
   {:label "User-Agent: " :detail "User agent string"}
   {:label "X-Request-ID: " :detail "Request ID header"}
   {:label "X-API-Key: " :detail "API key header"}
   {:label "Origin: " :detail "CORS origin"}
   {:label "Referer: " :detail "Referrer URL"}
   {:label "If-None-Match: " :detail "Conditional ETag"}
   {:label "If-Modified-Since: " :detail "Conditional date"}])

;; Build the items cache once. `kind` is the LSP CompletionItemKind:
;; 6 = Variable (flags), 13 = Enum (methods), 5 = Field (headers).
(fn build-items [source kind]
  (let [out []]
    (each [_ e (ipairs source)]
      (table.insert out {:label e.label
                         :detail e.detail
                         : kind
                         :insertText e.insertText
                         :insertTextFormat e.insertTextFormat}))
    out))

(local items [])
(each [_ it (ipairs (build-items flags 6))] (table.insert items it))
(each [_ it (ipairs (build-items methods 13))] (table.insert items it))
(each [_ it (ipairs (build-items headers 5))] (table.insert items it))

(local M {})

(fn M.new []
  (setmetatable {} {:__index M}))

(fn M.get_completions [self ctx callback]
  (let [shellutil (require :blink.sources.shellutil)]
    (if (not (shellutil.in_command ctx :curl))
        (callback {:is_incomplete_forward false :is_incomplete_backward false :items []})
        (callback {:is_incomplete_forward false :is_incomplete_backward false : items}))))

M