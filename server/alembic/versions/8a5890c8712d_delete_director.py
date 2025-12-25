"""Delete director

Revision ID: 8a5890c8712d
Revises: 4b159c16897d
Create Date: 2025-11-29 20:44:20.033245

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '8a5890c8712d'
down_revision: Union[str, Sequence[str], None] = '4b159c16897d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
