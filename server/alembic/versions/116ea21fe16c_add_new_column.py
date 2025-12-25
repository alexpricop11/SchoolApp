"""Add reset_code column to users

Revision ID: 116ea21fe16c
Revises: c964778d8006
Create Date: 2025-11-23 14:47:59.719819
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '116ea21fe16c'
down_revision: Union[str, Sequence[str], None] = 'c964778d8006'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add reset_code column to users table"""
    op.add_column('users', sa.Column('reset_code', sa.Integer(), nullable=True))


def downgrade() -> None:
    """Remove reset_code column from users table"""
    op.drop_column('users', 'reset_code')
