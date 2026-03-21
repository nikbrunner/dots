---
name: "dev:edit-article"
description: "Edit an article using DAG-based section ordering and focused rewrites. Use when reviewing or improving written content like blog posts, docs, or technical articles."
---

# Article Editing

Edit articles by analyzing structure as a directed acyclic graph, then rewriting section by section.

## Step 1: Analyze Structure

1. Divide the article into sections by headings
2. For each section, identify which other sections it depends on (information dependencies)
3. Confirm the current order respects the dependency DAG — if not, propose reordering
4. Present the structure to the user and confirm before proceeding

## Step 2: Rewrite Sections

For each section in DAG order:

1. Rewrite to improve clarity, coherence, and flow
2. Keep paragraphs under **240 characters** — force concision
3. Preserve the author's voice and intent
4. Flag sections where meaning is unclear rather than guessing

Present the edited article to the user for review.
