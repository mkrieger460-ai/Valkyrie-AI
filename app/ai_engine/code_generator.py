#!/usr/bin/env python3
"""
Valkyrie AI - Code Generation Engine
Handles AI-powered code generation using OpenAI API
"""

import openai
import os
import json
from datetime import datetime
import sqlite3
from pathlib import Path

class CodeGenerator:
    def __init__(self):
        """Initialize the Code Generator with OpenAI API"""
        self.api_key = os.getenv('OPENAI_API_KEY')
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY not found in environment variables")
        
        openai.api_key = self.api_key
        self.model = "gpt-3.5-turbo"
        self.db_path = Path(__file__).parent.parent.parent / 'valkyrie.db'
        self._init_database()
    
    def _init_database(self):
        """Initialize SQLite database for storing generated code"""
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS generated_code (
                id INTEGER PRIMARY KEY,
                prompt TEXT NOT NULL,
                language TEXT NOT NULL,
                code TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS code_snippets (
                id INTEGER PRIMARY KEY,
                name TEXT UNIQUE NOT NULL,
                language TEXT NOT NULL,
                code TEXT NOT NULL,
                description TEXT,
                tags TEXT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def generate_code(self, prompt: str, language: str = "python") -> dict:
        """
        Generate code using OpenAI API
        
        Args:
            prompt: User's description of what they want to build
            language: Programming language (python, javascript, cpp, java, rust)
        
        Returns:
            Dictionary with generated code and metadata
        """
        try:
            system_prompt = f"""You are Valkyrie, a legendary AI code generator inspired by Norse mythology.
Generate clean, efficient, and production-ready {language} code.
Follow best practices and include comments where necessary.
Output ONLY the code, no explanations."""

            response = openai.ChatCompletion.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=2000
            )
            
            code = response.choices[0].message.content.strip()
            
            # Save to database
            self._save_to_database(prompt, language, code)
            
            return {
                'status': 'success',
                'code': code,
                'language': language,
                'prompt': prompt,
                'timestamp': datetime.now().isoformat(),
                'tokens_used': response.usage.total_tokens
            }
        
        except openai.error.APIError as e:
            return {
                'status': 'error',
                'message': f'OpenAI API Error: {str(e)}',
                'code': ''
            }
        except Exception as e:
            return {
                'status': 'error',
                'message': f'Error generating code: {str(e)}',
                'code': ''
            }
    
    def _save_to_database(self, prompt: str, language: str, code: str):
        """Save generated code to database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute(
                'INSERT INTO generated_code (prompt, language, code) VALUES (?, ?, ?)',
                (prompt, language, code)
            )
            conn.commit()
            conn.close()
        except Exception as e:
            print(f"Database save error: {e}")
    
    def get_code_snippets(self, language: str = None, tags: str = None) -> list:
        """Retrieve code snippets from database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            query = 'SELECT id, name, language, description, tags FROM code_snippets WHERE 1=1'
            params = []
            
            if language:
                query += ' AND language = ?'
                params.append(language)
            
            if tags:
                query += ' AND tags LIKE ?'
                params.append(f'%{tags}%')
            
            cursor.execute(query, params)
            results = cursor.fetchall()
            conn.close()
            
            return [
                {
                    'id': r[0],
                    'name': r[1],
                    'language': r[2],
                    'description': r[3],
                    'tags': r[4]
                }
                for r in results
            ]
        except Exception as e:
            print(f"Database query error: {e}")
            return []
    
    def add_snippet(self, name: str, language: str, code: str, description: str = "", tags: str = ""):
        """Add a custom code snippet to database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute(
                'INSERT INTO code_snippets (name, language, code, description, tags) VALUES (?, ?, ?, ?, ?)',
                (name, language, code, description, tags)
            )
            conn.commit()
            conn.close()
            return {'status': 'success', 'message': 'Snippet added'}
        except sqlite3.IntegrityError:
            return {'status': 'error', 'message': 'Snippet name already exists'}
        except Exception as e:
            return {'status': 'error', 'message': str(e)}

# Initialize generator
try:
    generator = CodeGenerator()
except ValueError as e:
    print(f"Warning: {e}")
    generator = None
