# Complete CRUD Implementation Guide for Bitewise

This guide covers the full implementation flow for adding a new table with CRUD operations in your Bitewise application.

## Tech Stack Overview
- **Database**: Supabase (PostgreSQL)
- **Backend**: Python (FastAPI/Flask) with Alembic migrations  
- **Frontend**: React/Next.js
- **Migration Tools**: Both Supabase migrations AND Alembic

---

## 🗄️ Part 1: Database Layer

### Step 1: Create Supabase Migration

```bash
# Navigate to supabase directory
cd supabase

# Create a new migration (replace 'example_table' with your actual table name)
supabase migration new create_example_table

# This creates a file like: supabase/migrations/YYYYMMDDHHMMSS_create_example_table.sql
```

### Step 2: Define Table Schema

Edit the generated migration file with your table structure:

```sql
-- Example: supabase/migrations/20250116120000_create_example_table.sql

-- Create the table
CREATE TABLE IF NOT EXISTS "public"."example_table" (
    "id" bigint NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" text,
    "user_id" bigint NOT NULL,
    "status" character varying(50) DEFAULT 'active'::character varying,
    "metadata" jsonb,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Create sequence for auto-increment ID
CREATE SEQUENCE IF NOT EXISTS "public"."example_table_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Set sequence ownership
ALTER SEQUENCE "public"."example_table_id_seq" OWNED BY "public"."example_table"."id";

-- Set default value for ID
ALTER TABLE ONLY "public"."example_table" 
    ALTER COLUMN "id" SET DEFAULT nextval('"public"."example_table_id_seq"'::regclass);

-- Add primary key constraint
ALTER TABLE ONLY "public"."example_table"
    ADD CONSTRAINT "example_table_pkey" PRIMARY KEY ("id");

-- Add foreign key constraint (if applicable)
ALTER TABLE ONLY "public"."example_table"
    ADD CONSTRAINT "example_table_user_id_fkey" 
    FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;

-- Add unique constraints (if needed)
ALTER TABLE ONLY "public"."example_table"
    ADD CONSTRAINT "example_table_name_user_unique" UNIQUE ("name", "user_id");

-- Add check constraints (if needed)
ALTER TABLE ONLY "public"."example_table"
    ADD CONSTRAINT "valid_status" 
    CHECK (("status"::text = ANY (ARRAY['active'::text, 'inactive'::text, 'deleted'::text])));

-- Create indexes for performance
CREATE INDEX "ix_example_table_user_id" ON "public"."example_table" USING btree ("user_id");
CREATE INDEX "ix_example_table_status" ON "public"."example_table" USING btree ("status");
CREATE INDEX "ix_example_table_created_at" ON "public"."example_table" USING btree ("created_at");

-- Enable Row Level Security (RLS)
ALTER TABLE "public"."example_table" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own records" ON "public"."example_table"
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert their own records" ON "public"."example_table"
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update their own records" ON "public"."example_table"
    FOR UPDATE USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete their own records" ON "public"."example_table"
    FOR DELETE USING (auth.uid()::text = user_id::text);

-- Grant permissions
GRANT ALL ON TABLE "public"."example_table" TO "anon";
GRANT ALL ON TABLE "public"."example_table" TO "authenticated";
GRANT ALL ON TABLE "public"."example_table" TO "service_role";

GRANT ALL ON SEQUENCE "public"."example_table_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."example_table_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."example_table_id_seq" TO "service_role";
```

### Step 3: Apply Supabase Migration

```bash
# Apply migration to local database
supabase db reset

# Or apply to remote database
supabase db push

# Verify migration was applied
supabase db diff
```

---

## 🔧 Part 2: Backend Layer (Python)

### Step 1: Create Alembic Migration (if using additional backend migrations)

```bash
# Navigate to backend directory
cd backend

# Create new migration
alembic revision --autogenerate -m "create_example_table"

# Apply migration
alembic upgrade head
```

### Step 2: Create Pydantic Models

Create `backend/app/models/example_table.py`:

```python
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum

class ExampleStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    DELETED = "deleted"

class ExampleTableBase(BaseModel):
    name: str = Field(..., max_length=100)
    description: Optional[str] = None
    status: ExampleStatus = ExampleStatus.ACTIVE
    metadata: Optional[Dict[str, Any]] = None

class ExampleTableCreate(ExampleTableBase):
    user_id: int

class ExampleTableUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    description: Optional[str] = None
    status: Optional[ExampleStatus] = None
    metadata: Optional[Dict[str, Any]] = None

class ExampleTableInDB(ExampleTableBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class ExampleTableResponse(ExampleTableInDB):
    pass
```

### Step 3: Create Database Operations

Create `backend/app/crud/example_table.py`:

```python
from sqlalchemy.orm import Session
from typing import List, Optional
from app.models.example_table import ExampleTableCreate, ExampleTableUpdate
from app.db.models import ExampleTable  # SQLAlchemy model

class ExampleTableCRUD:
    def create(self, db: Session, *, obj_in: ExampleTableCreate, user_id: int) -> ExampleTable:
        db_obj = ExampleTable(
            **obj_in.dict(),
            user_id=user_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def get(self, db: Session, *, id: int, user_id: int) -> Optional[ExampleTable]:
        return db.query(ExampleTable).filter(
            ExampleTable.id == id,
            ExampleTable.user_id == user_id
        ).first()
    
    def get_multi(
        self, 
        db: Session, 
        *, 
        user_id: int,
        skip: int = 0, 
        limit: int = 100,
        status: Optional[str] = None
    ) -> List[ExampleTable]:
        query = db.query(ExampleTable).filter(ExampleTable.user_id == user_id)
        
        if status:
            query = query.filter(ExampleTable.status == status)
            
        return query.offset(skip).limit(limit).all()
    
    def update(
        self, 
        db: Session, 
        *, 
        db_obj: ExampleTable, 
        obj_in: ExampleTableUpdate
    ) -> ExampleTable:
        update_data = obj_in.dict(exclude_unset=True)
        
        for field, value in update_data.items():
            setattr(db_obj, field, value)
            
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def delete(self, db: Session, *, id: int, user_id: int) -> Optional[ExampleTable]:
        obj = self.get(db=db, id=id, user_id=user_id)
        if obj:
            db.delete(obj)
            db.commit()
        return obj

example_table_crud = ExampleTableCRUD()
```

### Step 4: Create API Endpoints

Create `backend/app/api/v1/endpoints/example_table.py`:

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.api.deps import get_current_user, get_db
from app.crud.example_table import example_table_crud
from app.models.example_table import (
    ExampleTableCreate,
    ExampleTableUpdate,
    ExampleTableResponse
)
from app.models.user import User

router = APIRouter()

@router.post("/", response_model=ExampleTableResponse)
def create_example_table(
    *,
    db: Session = Depends(get_db),
    example_table_in: ExampleTableCreate,
    current_user: User = Depends(get_current_user)
):
    """Create new example table record."""
    example_table = example_table_crud.create(
        db=db, obj_in=example_table_in, user_id=current_user.id
    )
    return example_table

@router.get("/", response_model=List[ExampleTableResponse])
def read_example_tables(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    status: Optional[str] = None,
    current_user: User = Depends(get_current_user)
):
    """Retrieve example table records for current user."""
    example_tables = example_table_crud.get_multi(
        db=db, user_id=current_user.id, skip=skip, limit=limit, status=status
    )
    return example_tables

@router.get("/{id}", response_model=ExampleTableResponse)
def read_example_table(
    *,
    db: Session = Depends(get_db),
    id: int,
    current_user: User = Depends(get_current_user)
):
    """Get example table record by ID."""
    example_table = example_table_crud.get(db=db, id=id, user_id=current_user.id)
    if not example_table:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Example table record not found"
        )
    return example_table

@router.put("/{id}", response_model=ExampleTableResponse)
def update_example_table(
    *,
    db: Session = Depends(get_db),
    id: int,
    example_table_in: ExampleTableUpdate,
    current_user: User = Depends(get_current_user)
):
    """Update example table record."""
    example_table = example_table_crud.get(db=db, id=id, user_id=current_user.id)
    if not example_table:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Example table record not found"
        )
    
    example_table = example_table_crud.update(
        db=db, db_obj=example_table, obj_in=example_table_in
    )
    return example_table

@router.delete("/{id}")
def delete_example_table(
    *,
    db: Session = Depends(get_db),
    id: int,
    current_user: User = Depends(get_current_user)
):
    """Delete example table record."""
    example_table = example_table_crud.delete(db=db, id=id, user_id=current_user.id)
    if not example_table:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Example table record not found"
        )
    return {"message": "Example table record deleted successfully"}
```

### Step 5: Register API Routes

Add to `backend/app/api/v1/api.py`:

```python
from app.api.v1.endpoints import example_table

api_router.include_router(
    example_table.router, 
    prefix="/example-tables", 
    tags=["example-tables"]
)
```

---

## 🎨 Part 3: Frontend Layer (React/Next.js)

### Step 1: Create API Service

Create `frontend/src/services/exampleTableService.js`:

```javascript
import api from './api'; // Your configured axios instance

export const exampleTableService = {
  // Get all example tables
  getAll: async (params = {}) => {
    const response = await api.get('/example-tables', { params });
    return response.data;
  },

  // Get example table by ID
  getById: async (id) => {
    const response = await api.get(`/example-tables/${id}`);
    return response.data;
  },

  // Create new example table
  create: async (data) => {
    const response = await api.post('/example-tables', data);
    return response.data;
  },

  // Update example table
  update: async (id, data) => {
    const response = await api.put(`/example-tables/${id}`, data);
    return response.data;
  },

  // Delete example table
  delete: async (id) => {
    const response = await api.delete(`/example-tables/${id}`);
    return response.data;
  }
};
```

### Step 2: Create React Components

#### List Component (`frontend/src/components/ExampleTableList.jsx`):

```jsx
import React, { useState, useEffect } from 'react';
import { exampleTableService } from '../services/exampleTableService';
import ExampleTableItem from './ExampleTableItem';
import ExampleTableForm from './ExampleTableForm';

const ExampleTableList = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingItem, setEditingItem] = useState(null);

  // Fetch items
  const fetchItems = async () => {
    try {
      setLoading(true);
      const data = await exampleTableService.getAll();
      setItems(data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch items');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, []);

  // Handle create/update
  const handleSave = async (data) => {
    try {
      if (editingItem) {
        await exampleTableService.update(editingItem.id, data);
      } else {
        await exampleTableService.create(data);
      }
      
      await fetchItems(); // Refresh list
      setShowForm(false);
      setEditingItem(null);
    } catch (err) {
      setError('Failed to save item');
      console.error(err);
    }
  };

  // Handle delete
  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this item?')) {
      try {
        await exampleTableService.delete(id);
        await fetchItems(); // Refresh list
      } catch (err) {
        setError('Failed to delete item');
        console.error(err);
      }
    }
  };

  // Handle edit
  const handleEdit = (item) => {
    setEditingItem(item);
    setShowForm(true);
  };

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div className="example-table-list">
      <div className="header">
        <h2>Example Tables</h2>
        <button 
          className="btn-primary"
          onClick={() => setShowForm(true)}
        >
          Add New Item
        </button>
      </div>

      {error && (
        <div className="error-message">
          {error}
        </div>
      )}

      <div className="items-grid">
        {items.map(item => (
          <ExampleTableItem
            key={item.id}
            item={item}
            onEdit={handleEdit}
            onDelete={handleDelete}
          />
        ))}
      </div>

      {items.length === 0 && !loading && (
        <div className="empty-state">
          <p>No items found. Create your first item!</p>
        </div>
      )}

      {showForm && (
        <ExampleTableForm
          item={editingItem}
          onSave={handleSave}
          onCancel={() => {
            setShowForm(false);
            setEditingItem(null);
          }}
        />
      )}
    </div>
  );
};

export default ExampleTableList;
```

#### Form Component (`frontend/src/components/ExampleTableForm.jsx`):

```jsx
import React, { useState, useEffect } from 'react';

const ExampleTableForm = ({ item, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    status: 'active',
    metadata: {}
  });
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (item) {
      setFormData({
        name: item.name || '',
        description: item.description || '',
        status: item.status || 'active',
        metadata: item.metadata || {}
      });
    }
  }, [item]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: null
      }));
    }
  };

  const validate = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    } else if (formData.name.length > 100) {
      newErrors.name = 'Name must be less than 100 characters';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validate()) return;
    
    try {
      setLoading(true);
      await onSave(formData);
    } catch (err) {
      console.error('Save failed:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <div className="modal-header">
          <h3>{item ? 'Edit Item' : 'Create New Item'}</h3>
          <button className="close-btn" onClick={onCancel}>×</button>
        </div>

        <form onSubmit={handleSubmit} className="form">
          <div className="form-group">
            <label htmlFor="name">Name *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              className={errors.name ? 'error' : ''}
              disabled={loading}
            />
            {errors.name && <span className="error-text">{errors.name}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="description">Description</label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows="3"
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="status">Status</label>
            <select
              id="status"
              name="status"
              value={formData.status}
              onChange={handleChange}
              disabled={loading}
            >
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="deleted">Deleted</option>
            </select>
          </div>

          <div className="form-actions">
            <button 
              type="button" 
              className="btn-secondary"
              onClick={onCancel}
              disabled={loading}
            >
              Cancel
            </button>
            <button 
              type="submit" 
              className="btn-primary"
              disabled={loading}
            >
              {loading ? 'Saving...' : (item ? 'Update' : 'Create')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ExampleTableForm;
```

#### Item Component (`frontend/src/components/ExampleTableItem.jsx`):

```jsx
import React from 'react';

const ExampleTableItem = ({ item, onEdit, onDelete }) => {
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString();
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'green';
      case 'inactive': return 'orange';
      case 'deleted': return 'red';
      default: return 'gray';
    }
  };

  return (
    <div className="item-card">
      <div className="item-header">
        <h4 className="item-name">{item.name}</h4>
        <span 
          className={`status-badge status-${item.status}`}
          style={{ backgroundColor: getStatusColor(item.status) }}
        >
          {item.status}
        </span>
      </div>

      {item.description && (
        <p className="item-description">{item.description}</p>
      )}

      <div className="item-meta">
        <small>Created: {formatDate(item.created_at)}</small>
        {item.updated_at !== item.created_at && (
          <small>Updated: {formatDate(item.updated_at)}</small>
        )}
      </div>

      <div className="item-actions">
        <button 
          className="btn-edit"
          onClick={() => onEdit(item)}
        >
          Edit
        </button>
        <button 
          className="btn-delete"
          onClick={() => onDelete(item.id)}
        >
          Delete
        </button>
      </div>
    </div>
  );
};

export default ExampleTableItem;
```

### Step 3: Create Page Component

Create `frontend/src/pages/ExampleTablePage.jsx`:

```jsx
import React from 'react';
import ExampleTableList from '../components/ExampleTableList';

const ExampleTablePage = () => {
  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Example Table Management</h1>
        <p>Manage your example table records</p>
      </div>
      
      <div className="page-content">
        <ExampleTableList />
      </div>
    </div>
  );
};

export default ExampleTablePage;
```

### Step 4: Add Routing

Add to your router configuration:

```jsx
// In your App.js or router configuration
import ExampleTablePage from './pages/ExampleTablePage';

// Add to your routes
<Route path="/example-tables" element={<ExampleTablePage />} />
```

### Step 5: Add Navigation

Add to your navigation menu:

```jsx
// In your navigation component
<NavLink to="/example-tables">
  Example Tables
</NavLink>
```

---

## 🎯 Part 4: Commands Summary

### Development Commands

```bash
# Database Operations
cd supabase
supabase migration new create_your_table
supabase db reset
supabase db push

# Backend Operations  
cd backend
alembic revision --autogenerate -m "create_your_table"
alembic upgrade head

# Run backend server
python -m uvicorn app.main:app --reload

# Frontend Operations
cd frontend
npm install
npm run dev

# Testing
npm test
python -m pytest
```

### Production Deployment

```bash
# Deploy Supabase migrations
supabase db push --linked

# Deploy backend
# (depends on your deployment platform)

# Deploy frontend  
npm run build
# Deploy build folder to your hosting platform
```

---

## 📝 Best Practices

### Database
- Always use transactions for multi-table operations
- Add proper indexes for query performance
- Use Row Level Security (RLS) for data protection
- Include audit fields (created_at, updated_at)

### Backend
- Use Pydantic models for validation
- Implement proper error handling
- Add logging for debugging
- Use dependency injection for database sessions
- Implement pagination for list endpoints

### Frontend
- Implement loading states
- Add error handling and user feedback
- Use React hooks for state management
- Implement proper form validation
- Add confirmation dialogs for destructive operations

### Security
- Validate all inputs on both frontend and backend
- Use JWT tokens for authentication
- Implement rate limiting
- Use HTTPS in production
- Sanitize user inputs to prevent XSS

---

## 🔧 Common Issues & Solutions

### Issue: Migration conflicts
**Solution**: Always pull latest migrations before creating new ones

### Issue: CORS errors in development
**Solution**: Configure CORS properly in your backend

### Issue: Authentication errors
**Solution**: Ensure JWT tokens are properly configured and validated

### Issue: Performance issues with large datasets
**Solution**: Implement pagination, indexing, and query optimization

---

This guide provides a complete template for implementing CRUD operations in your Bitewise application. Modify the table structure, field names, and business logic according to your specific requirements.