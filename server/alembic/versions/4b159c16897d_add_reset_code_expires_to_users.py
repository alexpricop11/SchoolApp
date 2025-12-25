"""Add reset_code_expires to users

Revision ID: 4b159c16897d
Revises: 116ea21fe16c
Create Date: 2025-11-23 14:50:59.524902

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '4b159c16897d'
down_revision: Union[str, Sequence[str], None] = '116ea21fe16c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Completează valorile NULL cu datetime curent
    op.execute("UPDATE students SET updated_at = NOW() WHERE updated_at IS NULL")

    # Acum poți seta NOT NULL
    op.alter_column('students', 'updated_at',
                    existing_type=postgresql.TIMESTAMP(),
                    nullable=False)

    # Adaugă coloana reset_code_expires în users
    op.add_column('users', sa.Column('reset_code_expires', sa.DateTime(), nullable=True))


def downgrade() -> None:
    op.drop_column('users', 'reset_code_expires')
    op.alter_column('students', 'updated_at',
               existing_type=postgresql.TIMESTAMP(),
               nullable=True)
