import logging
from datetime import datetime
from typing import List
from uuid import UUID

from sqlalchemy.orm import Session

from thymis_controller import db_models, models

logger = logging.getLogger(__name__)


def get_generations(
    db_session: Session,
    deployment_info_id: UUID,
    limit: int,
) -> List[db_models.SystemGeneration]:
    return (
        db_session.query(db_models.SystemGeneration)
        .filter(db_models.SystemGeneration.deployment_info_id == deployment_info_id)
        .order_by(db_models.SystemGeneration.generation.desc())
        .limit(limit)
        .all()
    )


def _delete_remove_generations(
    db_session: Session,
    list_of_current_generations: List[int],
) -> None:
    num_removed = (
        db_session.query(db_models.SystemGeneration)
        .filter(
            db_models.SystemGeneration.generation.notin_(list_of_current_generations)
        )
        .delete()
    )
    db_session.commit()
    if num_removed:
        logger.info("Deleted %d generations", num_removed)


def add_generations(
    db_session: Session,
    deployment_info_id: UUID,
    list_of_generations: List[models.SystemGeneration],
) -> None:
    list_of_current_generations = []
    for system_generation in list_of_generations:
        list_of_current_generations = system_generation.generation
        sys_gen = db_models.SystemGeneration(
            deployment_info_id=deployment_info_id,
            generation=system_generation.generation,
            date=system_generation.date,
            nixos_version=system_generation.nixos_version,
            kernel_version=system_generation.kernel_version,
            configuration_revision=system_generation.configuration_revision,
            current=system_generation.current,
        )

        db_session.add(sys_gen)
    db_session.commit()
    _delete_remove_generations(db_session, list_of_current_generations)
    db_session.refresh(sys_gen)
