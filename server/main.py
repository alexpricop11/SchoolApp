import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "api:app",
        host="172.22.240.1",
        port=8000,
        reload=True
    )
