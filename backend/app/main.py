from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

from app.core.config import logger
from app.middleware.audit import AuditMiddleware
from app.routes import community, hazard, health, reports, risk, root, safezones

logger.info("Setting up the main API")

# Middlewares
app = FastAPI(title="Klima API")
app.add_middleware(AuditMiddleware)

# Routes
app.include_router(root.router, tags=["main"])
app.include_router(health.router)
app.include_router(hazard.router)
app.include_router(reports.router)
app.include_router(risk.router)
app.include_router(safezones.router)
app.include_router(community.router)

# Alerts
Instrumentator().instrument(app).expose(app)
