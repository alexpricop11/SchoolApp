"""Add timestamps and fix user relationship in students table

Revision ID: 6ad18da8031c
Revises: c130c0895c69
Create Date: 2025-11-21 13:35:50.498607

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql.functions import func

# revision identifiers, used by Alembic.
revision: str = '6ad18da8031c'
down_revision: Union[str, Sequence[str], None] = 'c130c0895c69'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.add_column('students', sa.Column('created_at', sa.DateTime(), server_default=func.now(), nullable=False))
    op.add_column('students', sa.Column('updated_at', sa.DateTime(), nullable=True))


def downgrade():
    op.drop_column('students', 'created_at')
    op.drop_column('students', 'updated_at')
