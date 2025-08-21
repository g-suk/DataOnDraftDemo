# 🍺 Beermantics: AI-Powered Beer Recommendation System

A complete Snowflake-based solution that scrapes live beer data from Luce Line Brewing and provides intelligent beer recommendations using vector embeddings and Snowflake Cortex AI.

## Overview

This system combines web scraping, vector embeddings, and semantic search to create an intelligent beer recommendation engine. It scrapes real-time tap list data from Luce Line Brewing, compares it against a reference database of popular craft beers, and provides personalized recommendations using AI.

## Prerequisites

- Snowflake account with the following features enabled:
  - Snowflake Notebooks
  - Snowflake Cortex AI
  - External network access capabilities
- `ACCOUNTADMIN` privileges (required for initial setup)
- Access to Snowflake Intelligence

## Setup Instructions

### Step 1: Environment Setup and Reference Data

Run the setup script to create the database, tables, and load reference beer data:

```sql
-- Execute setup.sql in a Snowflake worksheet
-- This creates:
-- - snowflake_intelligence_admin_rl role
-- - data_on_draft database
-- - LUCE_LINE_TAP_LIST table
-- - REFERENCE_BEERS table with 200+ popular craft beers
-- - Vector embeddings for all reference beers
```

**File**: `setup.sql`

This script creates the foundational database schema and populates a comprehensive reference table with over 200 popular craft beers across various styles, complete with descriptions and vector embeddings.

### Step 2: Import and Configure the Scraping Notebook

1. Navigate to **Snowsight** → **Projects** → **Notebooks**
2. Click **Import Notebook** and upload `LUCE_LINE_BEER_NOTEBOOK.ipynb`
3. Configure the notebook settings:
   - **Runtime**: Snowflake Warehouse Runtime 2.0
   - **Warehouse**: SNOWFLAKE_INTELLIGENCE_WH
   - Select **Create**

<img src="Images/notebook%20create%20settings.png" alt="Notebook Creation Settings" width="60%" height="60%">

Once the Notebook 
4. **Packages**: Add `beautifulsoup4` to the package list

<img src="Images/add%20notebook%20packages.png" alt="Add Notebook Package" width="50%" height="50%">

5. **Start** the Notebook Session, if not already started.
6. Run each cell.
### Step 3: Role Configuration

Ensure you're using the correct role in Snowsight:
- click on your user in the bottom left of the screen and select role ***snowflake_intelligence_admin_rl***

<img src="Images/snowsight%20select%20user.png" alt="Select User" width="50%" height="50%">

<img src="Images/snowflake%20intel%20role.png" alt="Select User" width="50%" height="50%">

This role has the necessary permissions to:
- Access external networks for web scraping
- Create and manage stored procedures
- Generate vector embeddings using Cortex AI

### Step 4: Create Semantic Model

1. Navigate to **Snowsight** → **AI & ML** → **Semantic Models**
2. Click **Create Semantic Model**
3. Upload the `BEERMANTICS_VECTOR.yaml` file
4. This creates a semantic layer that enables:
   - Natural language queries about beer data
   - Vector similarity searches between Luce Line beers and reference beers
   - Intelligent recommendations based on style and flavor profiles

### Step 5: Create AI Agent

1. In **Snowsight**, navigate to **AI & ML** → **Agents**
2. Create a new agent using the `BEERMANTICS_VECTOR` semantic in the Cortex Analyst section

### Step 6: Access Snowflake Intelligence

Navigate to **Snowflake Intelligence** to interact with your beer recommendation system using natural language queries such as:

- "I like Hazy Little Thing from Sierra Nevada, what beer from Luce Line would I like?"
- "What's the lowest ABV beer available?"
- "Recommend something similar to Foggy Bottom"
- "I want a crisp, refreshing beer for a hot day"

## System Components

### Database Schema

- **LUCE_LINE_TAP_LIST**: Live scraped data from Luce Line Brewing
  - Beer names, styles, ABV, descriptions
  - Vector embeddings for semantic search
  - Brewery information and scrape timestamps

- **REFERENCE_BEERS**: Curated database of 200+ popular craft beers
  - Comprehensive style coverage (IPAs, Lagers, Stouts, Sours, etc.)
  - Professional descriptions and tasting notes
  - Vector embeddings for comparison matching

### Key Features

1. **Live Data Scraping**: Automatically extracts current tap list from Luce Line Brewing's website
2. **Vector Similarity**: Uses Snowflake Cortex to find similar beers based on style and flavor descriptions
3. **Smart Recommendations**: Provides personalized suggestions based on user preferences
4. **Natural Language Interface**: Ask questions in plain English through Snowflake Intelligence

### Semantic Model Capabilities

The YAML configuration enables sophisticated queries including:

- Style-based matching with preference weighting
- Flavor profile similarity using vector embeddings
- ABV-based filtering and recommendations
- Cross-referencing between local and reference beer databases
