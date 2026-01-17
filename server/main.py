import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "api:app",
        host="10.240.0.129",
        port=8000,
        reload=True
    )
