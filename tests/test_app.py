import pytest

from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_index_route(client):
    """Test the index route returns correct template"""
    response = client.get("/")
    assert response.status_code == 200
    assert b"<title>Hello Azure - Python Quickstart</title>" in response.data


def test_favicon_route(client):
    """Test favicon.ico is served correctly"""
    response = client.get("/favicon.ico")
    assert response.status_code == 200
    assert response.mimetype == "image/vnd.microsoft.icon"


def test_hello_route_with_name(client):
    """Test hello route with a name parameter"""
    response = client.post("/hello", data={"name": "Test User"})
    assert response.status_code == 200
    assert (
        b"Test User" in response.data
    )  # Less strict assertion that checks if name appears anywhere


def test_hello_route_without_name(client):
    """Test hello route redirects when no name provided"""
    response = client.post("/hello", data={})
    assert response.status_code == 302
    assert response.headers["Location"] == "/"
