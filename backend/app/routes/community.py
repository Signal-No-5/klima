"""Community announcement feed."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Query
from klima_schema import CommunityPostOut

from app.services import seed

router = APIRouter(prefix="/community", tags=["community"])


@router.get("/posts", response_model=list[CommunityPostOut])
def list_posts(
    barangay: Annotated[
        str | None, Query(description="Match posts tagged for a barangay")
    ] = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
) -> list[CommunityPostOut]:
    """Pinned posts first, then newest.

    Sourced from ``backend/data/seed/community_posts.json`` until LGU authoring
    exists. ``barangay`` matches against post tags, which is how seed posts
    record their audience.
    """
    posts = list(seed.community_posts())
    if barangay:
        needle = barangay.strip().lower()
        posts = [
            post
            for post in posts
            if any(needle in tag.lower() for tag in post.tags or [])
        ]
    posts.sort(key=lambda post: (not post.is_pinned, -post.timestamp.timestamp()))
    return posts[:limit]
