from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

from app.api.v1.api import api_router
from app.core.config import logger
from app.middleware.audit import AuditMiddleware
from app.routes import root

logger.info("Setting up the main API")

# Middlewares
app = FastAPI(title="Klima API")
app.add_middleware(AuditMiddleware)

# Routes — root paths match mobile AppConstants; /api/v1 is the versioned mirror
app.include_router(root.router, tags=["main"])
app.include_router(api_router)
app.include_router(api_router, prefix="/api/v1")

# Alerts
Instrumentator().instrument(app).expose(app)
