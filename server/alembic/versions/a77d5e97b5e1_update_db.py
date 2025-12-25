"""update db

Revision ID: a77d5e97b5e1
Revises: ac953f6aab19
Create Date: 2025-11-30 17:07:07.318194

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a77d5e97b5e1'
down_revision: Union[str, Sequence[str], None] = 'ac953f6aab19'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
