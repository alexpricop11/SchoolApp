"""Add timestamps and fix user relationship in students table

Revision ID: c964778d8006
Revises: 88666a2b7160
Create Date: 2025-11-21 13:38:59.562507

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql.functions import func

# revision identifiers, used by Alembic.
revision: str = 'c964778d8006'
down_revision: Union[str, Sequence[str], None] = '88666a2b7160'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.add_column('students', sa.Column('created_at', sa.DateTime(), server_default=func.now(), nullable=False))
    op.add_column('students', sa.Column('updated_at', sa.DateTime(), nullable=True))


def downgrade():
    op.drop_column('students', 'created_at')
    op.drop_column('students', 'updated_at')
