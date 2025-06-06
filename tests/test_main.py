import pytest
from xprocess import ProcessStarter
import requests
from src.main import fibonacci
import pathlib


@pytest.mark.parametrize(
    "n, expected", [(0, [0]), (10, [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]), (1, [0, 1])]
)
def test_fibonacci(n, expected):
    assert fibonacci(n) == expected


def test_fibonacci_negative():
    with pytest.raises(ValueError):
        fibonacci(-1)


def test_fibonacci_large():
    with pytest.raises(ValueError):
        fibonacci(20579)


@pytest.fixture
def get_fibs_server(xprocess):
    # We're in the tests directory. Get the project directory
    project_dir = pathlib.Path(__file__).parents[1]

    class Starter(ProcessStarter):
        pattern = "Starting server"
        timeout = 5
        terminate_on_interrupt = True
        args = ["python3", pathlib.Path(project_dir, "src", "main.py")]

    xprocess.ensure("get_fibs_server", Starter)
    yield
    print("Stopping server")
    xprocess.getinfo("get_fibs_server").terminate()


def test_GetFibs(get_fibs_server):
    # Test the server with valid input
    response = requests.get("http://localhost:8000/?n=10")
    assert response.status_code == 200
    assert response.text == "0, 1, 1, 2, 3, 5, 8, 13, 21, 34"

    # Test the server with no input
    response = requests.get("http://localhost:8000/")
    assert response.status_code == 422

    # Test the server with invalid input
    response = requests.get("http://localhost:8000/?n=abc")
    assert response.status_code == 422
