"""Delete director

Revision ID: ac953f6aab19
Revises: 8a5890c8712d
Create Date: 2025-11-29 22:19:51.956339

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ac953f6aab19'
down_revision: Union[str, Sequence[str], None] = '8a5890c8712d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # 1) Add the new column to teachers (use server_default to avoid locking issues)
    op.add_column(
        "teachers",
        sa.Column("is_director", sa.Boolean(), nullable=False, server_default=sa.text("false")),
    )

    # 2) Drop the directors table
    op.drop_table("directors")

    # 3) Remove server_default so schema reflects default behavior at DB level
    op.alter_column("teachers", "is_director", server_default=None)


def downgrade() -> None:
    """Downgrade schema."""
    # 1) Recreate the directors table (minimal schema; adjust if your original contained extra columns)
    op.create_table(
        "directors",
        sa.Column("user_id", sa.String(length=36), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
    )

    # 2) Remove the is_director column from teachers
    op.drop_column("teachers", "is_director")
