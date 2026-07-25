"""Aggregate v1 routers."""

from fastapi import APIRouter

from app.api.v1.endpoints import klima

api_router = APIRouter()
api_router.include_router(klima.router)
