import uuid
import datetime
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from thymis_controller.database.base import Base

if TYPE_CHECKING:
    from thymis_controller.db_models.deployment_info import DeploymentInfo


class SystemGeneration(Base):
    __tablename__ = "system_generations"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    deployment_info_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("deployment_info.id"), nullable=True
    )
    deployment_info: Mapped["DeploymentInfo"] = relationship(lazy=True)

    generation: Mapped[int] = mapped_column(nullable=False)
    build_date: Mapped[datetime.datetime] = mapped_column(nullable=False)
    nixos_version: Mapped[str] = mapped_column(nullable=False)
    kernel: Mapped[str] = mapped_column(nullable=False)
    current: Mapped[bool] = mapped_column(nullable=False)
    # For now I am ignoring specialisations
