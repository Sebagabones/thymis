import datetime
from typing import List

from pydantic import BaseModel

__all__ = [
    "SystemGeneration",
]


class SystemGeneration(BaseModel):
    generation: int
    date: datetime.datetime  # Follows form: YYYY-MM-DD HH:MM:SS
    nixos_version: str  # Not a plain number, e.g.: "26.05.20260308.9dcb002"
    kernel_version: str  # Can either be "Unknown" or of format "6.18.20"
    configuration_revision: (
        str  # Can either be "Unknown" or (TODO: Work out what else this can be)
    )
    specialisations: List[str]  # Can be empty, TODO: Double check the type of content
    current: bool
