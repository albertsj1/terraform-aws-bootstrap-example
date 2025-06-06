from http.server import BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import time
import sys


def fibonacci(n: int) -> list[int]:
    """
    Return the first `n` Fibonacci numbers.

    Args:
        n (int): The number of Fibonacci numbers to generate.

    Returns:
        list[int]: A list of the first `n` Fibonacci numbers.

    Raises:
        ValueError: If `n` is negative or greater than 20578.

    NOTE: Anything larger than n=20578 will generate an error for integer string conversion, as the default
    limit is 4300 digits. This can be changed by setting the sys.setrecursionlimit() to a higher value.
    See CVE-2020-10735 for more information.
    """
    a = 0
    b = 1

    # Check is n is less
    # than 0
    if n < 0:
        raise ValueError(f"n={n} is negative. Please enter a positive number.")
        return None

    elif n > 20578:
        raise ValueError(f"n={n} is too large. Please enter a number less than 20579.")

    # Check is n is equal
    # to 0
    elif n == 0:
        return [0]

    # Check if n is equal to 1
    elif n == 1:
        return [0, 1]
    else:
        fib_nums = [0, 1]
        # Calculate the Fibonacci numbers and store them in a list.
        # The first two Fibonacci numbers are already known.
        # So start with i=2 and calculate the next Fibonacci number
        # until we reach n.
        for i in range(2, n):
            c = a + b
            a = b
            b = c
            fib_nums.append(c)
        return fib_nums


class GetFibs(BaseHTTPRequestHandler):
    """
    A request handler for getting Fibonacci numbers.

    This handler responds to GET requests with the first `n` Fibonacci numbers,
    where `n` is a parameter in the query string.
    """

    def do_GET(self):
        """
        Handle a GET request.

        Responds with the first `n` Fibonacci numbers, where `n` is a parameter
        in the query string. If `n` is not provided or is not a valid integer,
        responds with a 422 status code.
        """
        request_start_time = time.time()
        query = urlparse(self.path).query
        params = parse_qs(query)

        if self.path == "/health":
            self.send_response(200, "OK")
            self.end_headers()
        else:
            if "n" not in params:
                self.send_response(422, "Please pass a number n in the query string.")
                self.end_headers()
            else:
                try:
                    key = int(params["n"][0])
                    nums = fibonacci(key)

                    # convert nums from int to string list
                    str_nums = [str(n) for n in nums]
                    final_nums = ", ".join(str_nums)

                    self.send_response(200)
                    self.end_headers()
                    self.wfile.write(bytes(final_nums, "UTF-8"))
                except (ValueError, IndexError) as e:
                    self.send_response(422, f"{type(e).__name__}: {e.args[0]}")
                    self.end_headers()

        self.log_message(f"Request took {time.time() - request_start_time} seconds.")
        return


if __name__ == "__main__":
    """
    Start an HTTP server on port 8000.

    The server uses `GetFibs` to handle requests.
    """
    from http.server import HTTPServer

    address = ("", 8000)
    print(f"Starting server {address}, use <Ctrl-C> to stop")
    sys.stdout.flush()
    httpd = HTTPServer(address, GetFibs)
    httpd.serve_forever()
