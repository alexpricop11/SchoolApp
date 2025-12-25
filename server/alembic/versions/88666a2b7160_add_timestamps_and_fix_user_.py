"""Add timestamps and fix user relationship in students table

Revision ID: 88666a2b7160
Revises: 6ad18da8031c
Create Date: 2025-11-21 13:37:48.215650

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '88666a2b7160'
down_revision: Union[str, Sequence[str], None] = '6ad18da8031c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
