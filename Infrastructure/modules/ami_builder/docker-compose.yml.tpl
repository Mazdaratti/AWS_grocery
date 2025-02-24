services:
  frontend:
    image: ${frontend_image}:latest
    container_name: frontend
    networks:
      - app-network
    volumes:
      - frontend-build:/app/build
    command: >
      sh -c "touch /app/build/BUILD_COMPLETE"

  backend:
    image: ${backend_image}:latest
    container_name: backend
    ports:
      - "5000:5000"
    networks:
      - app-network
    volumes:
      - frontend-build:/app/../frontend/build:ro
    depends_on:
      - frontend
    command: >
      sh -c 'while [ ! -f /app/../frontend/build/BUILD_COMPLETE ]; do
      echo "Waiting for frontend build..."; sleep 5; done &&
      gunicorn --bind 0.0.0.0:5000 run:app'
    restart: always

volumes:
  frontend-build: {}

networks:
  app-network:
    driver: bridge