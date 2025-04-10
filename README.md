# Full Stack FastAPI Project

A full-stack application with a FastAPI backend, React frontend, and PostgreSQL database, all containerized with Docker.

## Features

- **Frontend**: React application with modern UI
- **Backend**: FastAPI with SQLAlchemy ORM
- **Database**: PostgreSQL for data persistence
- **Authentication**: OAuth2 with JWT tokens
- **Docker**: Full containerization of all services
- **Nginx**: Serving static frontend files

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Git

### Setup

1. Clone the repository:
   ```
   git clone <repository-url>
   cd <repository-name>
   ```

2. Create environment files:
   ```
   cp backend/.env.example backend/.env
   cp frontend/.env.example frontend/.env
   ```

3. Start the application:
   ```
   docker-compose up -d
   ```

4. The application will be available at:
   - Frontend: http://localhost:5030
   - Backend API: http://localhost:8010
   - API Documentation: http://localhost:8010/docs

### Default Credentials

- Email: admin@example.com (set in backend/.env as FIRST_SUPERUSER)
- Password: changeme123 (set in backend/.env as FIRST_SUPERUSER_PASSWORD)

## Development

### Project Structure

```
├── backend/                # FastAPI backend
│   ├── app/                # Application code
│   ├── Dockerfile          # Backend container config
│   └── .env                # Backend environment variables
├── frontend/               # React frontend
│   ├── src/                # Source code
│   ├── Dockerfile          # Frontend container config
│   └── .env                # Frontend environment variables
└── docker-compose.yml      # Docker services configuration
```

## License

[MIT License](LICENSE)