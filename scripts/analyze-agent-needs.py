#!/usr/bin/env python3
"""
Agent Needs Analyzer - Определение потребности в агентах для проекта

Анализирует тип проекта и определяет, какие AI-агенты нужны.
"""

from typing import Dict, List, Optional
from dataclasses import dataclass
from enum import Enum


class AgentType(Enum):
    """Типы агентов"""
    COORDINATOR = "coordinator"
    CODE_ASSISTANT = "code-assistant"
    REVIEWER = "reviewer"
    DOCUMENTATION = "documentation"
    DEBUGGER = "debugger"
    TESTER = "tester"
    API_DEVELOPER = "api-developer"
    FRONTEND_DEV = "frontend-dev"
    DATA_ENGINEER = "data-engineer"
    ML_ENGINEER = "ml-engineer"
    DEVOPS = "devops"
    SECURITY = "security"
    PERFORMANCE = "performance"
    UX_DESIGNER = "ux-designer"


@dataclass
class AgentRecommendation:
    """Рекомендация по агенту"""
    agent_type: AgentType
    priority: int  # 1-100, выше = важнее
    required: bool  # True = обязательно, False = опционально
    reason: str  # Почему нужен
    default_model: str  # Модель по умолчанию
    estimated_cost: str  # Оценка затрат (tokens/session)


class AgentNeedsAnalyzer:
    """Анализатор потребности в агентах"""

    # База знаний о требованиях для разных типов проектов
    PROJECT_AGENTS_DB = {
        "telegram-bot": [
            {
                "agent_type": AgentType.CODE_ASSISTANT,
                "priority": 90,
                "required": True,
                "reason": "Пишется код на Python (aiogram), нужен помощник",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.COORDINATOR,
                "priority": 80,
                "required": True,
                "reason": "Агенты специализируются (specifier, docwriter, etc.), нужна координация",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DOCUMENTATION,
                "priority": 60,
                "required": False,
                "reason": "Документация для API handlers, FSM states",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.TESTER,
                "priority": 70,
                "required": False,
                "reason": "Тестирование FSM transitions, handlers",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DEBUGGER,
                "priority": 50,
                "required": False,
                "reason": "Отладка асинхронного кода",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],

        "web-service": [
            {
                "agent_type": AgentType.COORDINATOR,
                "priority": 80,
                "required": True,
                "reason": "Координация между backend/frontend/devops",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.API_DEVELOPER,
                "priority": 90,
                "required": True,
                "reason": "Разработка REST/GraphQL API",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.FRONTEND_DEV,
                "priority": 85,
                "required": True,
                "reason": "Frontend разработка (React/Vue/Angular)",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.TESTER,
                "priority": 80,
                "required": False,
                "reason": "API testing, E2E tests",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DOCUMENTATION,
                "priority": 70,
                "required": False,
                "reason": "API docs, OpenAPI spec",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.SECURITY,
                "priority": 60,
                "required": False,
                "reason": "Security review, auth patterns",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],

        "ai-agent": [
            {
                "agent_type": AgentType.COORDINATOR,
                "priority": 90,
                "required": True,
                "reason": "Рой агентов требует координатора",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.ML_ENGINEER,
                "priority": 90,
                "required": True,
                "reason": "ML модели, RAG, векторные базы",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DATA_ENGINEER,
                "priority": 80,
                "required": True,
                "reason": "ETL, data pipelines, transformations",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.API_DEVELOPER,
                "priority": 70,
                "required": False,
                "reason": "FastAPI backend для AI агента",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.TESTER,
                "priority": 70,
                "required": False,
                "reason": "Тестирование ML моделей, RAG",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],

        "data-pipeline": [
            {
                "agent_type": AgentType.COORDINATOR,
                "priority": 70,
                "required": True,
                "reason": "Координация ETL задач",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DATA_ENGINEER,
                "priority": 95,
                "required": True,
                "reason": "Airflow DAGs, SQL, transformations",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.TESTER,
                "priority": 80,
                "required": False,
                "reason": "Data validation, pipeline tests",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DOCUMENTATION,
                "priority": 60,
                "required": False,
                "reason": "Data dictionary, lineage docs",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],

        "microservices": [
            {
                "agent_type": AgentType.COORDINATOR,
                "priority": 90,
                "required": True,
                "reason": "Много сервисов = сложная координация",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.API_DEVELOPER,
                "priority": 90,
                "required": True,
                "reason": "gRPC API development",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DEVOPS,
                "priority": 85,
                "required": True,
                "reason": "K8s, Istio, deployment automation",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.SECURITY,
                "priority": 70,
                "required": False,
                "reason": "Service mesh security, mTLS",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.TESTER,
                "priority": 80,
                "required": False,
                "reason": "Contract testing, integration tests",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.PERFORMANCE,
                "priority": 60,
                "required": False,
                "reason": "Load testing, optimization",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],

        "fullstack": [
            {
                "agent_type": AgentType.COORDINATOR,
                "priority": 85,
                "required": True,
                "reason": "Fullstack = много технологий, нужна координация",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.API_DEVELOPER,
                "priority": 90,
                "required": True,
                "reason": "Backend API (NestJS/Go/Python)",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.FRONTEND_DEV,
                "priority": 90,
                "required": True,
                "reason": "Frontend (React/Next.js/Vue)",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.TESTER,
                "priority": 80,
                "required": False,
                "reason": "E2E tests, integration",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DOCUMENTATION,
                "priority": 70,
                "required": False,
                "reason": "API docs, component docs",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.UX_DESIGNER,
                "priority": 50,
                "required": False,
                "reason": "UI/UX design guidance",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],

        "cli-tool": [
            {
                "agent_type": AgentType.CODE_ASSISTANT,
                "priority": 90,
                "required": True,
                "reason": "CLI код требует строгой структуры",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.TESTER,
                "priority": 70,
                "required": False,
                "reason": "CLI testing, argument parsing",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DOCUMENTATION,
                "priority": 60,
                "required": False,
                "reason": "Man pages, usage examples",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],

        "presentation": [
            {
                "agent_type": AgentType.COORDINATOR,
                "priority": 70,
                "required": False,
                "reason": "Минимальная координация",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.UX_DESIGNER,
                "priority": 80,
                "required": False,
                "reason": "Презентации требуют хорошего дизайна",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
            {
                "agent_type": AgentType.DOCUMENTATION,
                "priority": 60,
                "required": False,
                "reason": "Содержимое слайдов",
                "estimated_cost": "~5000 tokens/session",
                "default_model": "gpt-4"
            },
        ],
    }

    def analyze(self, project_type: str, custom_context: Optional[Dict] = None) -> List[AgentRecommendation]:
        """
        Анализировать потребность в агентах для типа проекта

        Args:
            project_type: Тип проекта (telegram-bot, web-service, etc.)
            custom_context: Дополнительный контекст (особые требования)

        Returns:
            Список рекомендаций по агентам
        """

        if project_type not in self.PROJECT_AGENTS_DB:
            # Fallback: базовый набор для неизвестного типа
            return [
                AgentRecommendation(
                    agent_type=AgentType.COORDINATOR,
                    priority=80,
                    required=True,
                    reason="Координатор для организации работы",
                    default_model="gpt-4",
                    estimated_cost="~5000 tokens/session"
                )
            ]

        recommendations = []

        # Получаем базовые рекомендации для типа проекта
        base_recs = self.PROJECT_AGENTS_DB[project_type]

        # Применяем custom context если есть
        if custom_context:
            base_recs = self._apply_custom_context(base_recs, custom_context)

        # Конвертируем в AgentRecommendation
        for rec in base_recs:
            recommendations.append(AgentRecommendation(**rec))

        # Сортируем по приоритету
        recommendations.sort(key=lambda x: x.priority, reverse=True)

        return recommendations

    def _apply_custom_context(self, base_recs: List[Dict], custom_context: Dict) -> List[Dict]:
        """Применить кастомный контент к рекомендациям"""

        modified = []

        for rec in base_recs:
            modified_rec = rec.copy()

            # Проверяем кастомные требования
            if custom_context.get("has_code", True):
                # Убедимся, что code assistant включен
                if rec["agent"] == AgentType.CODE_ASSISTANT:
                    modified_rec["required"] = True
                    modified_rec["priority"] = max(modified_rec["priority"], 90)

            if custom_context.get("complexity") == "high":
                # Высокая сложность = нужен координатор
                if rec["agent"] == AgentType.COORDINATOR:
                    modified_rec["priority"] += 20

            if custom_context.get("testing_first", False):
                # Тестирование не приоритет
                for rec in modified:
                    if rec["agent"] == AgentType.TESTER:
                        rec["priority"] -= 30
                        rec["required"] = False

            modified.append(modified_rec)

        return modified

    def get_recommendation_summary(self, recommendations: List[AgentRecommendation]) -> str:
        """Сгенерировать сводку рекомендаций для показа пользователю"""

        if not recommendations:
            return "Нет рекомендаций"

        lines = ["📋 Recommended agents for project:\n"]

        for i, rec in enumerate(recommendations, 1):
            required_mark = "✅ REQUIRED" if rec.required else "☐ OPTIONAL"
            priority_mark = self._get_priority_mark(rec.priority)

            agent_name = rec.agent_type.value.replace("-", " ").title()
            cost = rec.estimated_cost

            lines.append(
                f"{i}. {agent_name} {required_mark} {priority_mark}\n"
                f"   Priority: {rec.priority}/100\n"
                f"   Purpose: {rec.reason}\n"
                f"   Model: {rec.default_model}\n"
                f"   Cost: {cost}\n"
            )

        return "\n".join(lines)

    def _get_priority_mark(self, priority: int) -> str:
        """Получить визуальный маркер приоритета"""
        if priority >= 90:
            return "🔴 HIGH"
        elif priority >= 70:
            return "🟡 MEDIUM"
        else:
            return "🟢 LOW"

    def format_for_dialogue(self, recommendations: List[AgentRecommendation]) -> str:
        """Форматировать рекомендации для показа пользователю (диалог)"""

        lines = ["🤖 Проанализирован тип проекта, рекомендую следующие агенты:\n"]

        for i, rec in enumerate(recommendations, 1):
            required_mark = "✅" if rec.required else "○"

            # Определяем краткое имя
            agent_names = {
                AgentType.COORDINATOR: "Координатор",
                AgentType.CODE_ASSISTANT: "Code Assistant",
                AgentType.REVIEWER: "Ревьюер",
                AgentType.DOCUMENTATION: "Документатор",
                AgentType.TESTER: "Тестировщик",
                AgentType.API_DEVELOPER: "API разработчик",
                AgentType.FRONTEND_DEV: "Frontend разработчик",
                AgentType.DATA_ENGINEER: "Data инженер",
                AgentType.ML_ENGINEER: "ML инженер",
            }

            name = agent_names.get(rec.agent_type, rec.agent_type.value)
            priority_words = self._priority_to_words(rec.priority)

            lines.append(
                f"   [{i}] {name} {required_mark}\n"
                f"       Приоритет: {priority_words}\n"
                f"       Зачем: {rec.reason}\n"
            )

        return "\n".join(lines)

    def _priority_to_words(self, priority: int) -> str:
        """Конвертировать числовой приоритет в слова"""
        if priority >= 90:
            return "высокий"
        elif priority >= 70:
            return "средний"
        else:
            return "низкий"

    def estimate_total_cost(self, recommendations: List[AgentRecommendation]) -> Dict:
        """Оценить общую стоимость (tokets per session)"""

        required = [r for r in recommendations if r.required]
        optional = [r for r in recommendations if not r.required]

        # Ориентировочная стоимость в токенах за сессию
        costs = {
            "required": sum([self._parse_cost(r.estimated_cost) for r in required]),
            "optional": sum([self._parse_cost(r.estimated_cost) for r in optional]),
            "total": 0
        }

        costs["total"] = costs["required"] + costs["optional"]

        return costs

    def _parse_cost(self, cost_str: str) -> int:
        """Парсить строку стоимости в число токенов"""
        import re

        match = re.search(r"~?(\d+)", cost_str)
        return int(match.group(1)) if match else 5000


# CLI interface для тестирования
def main():
    """CLI для тестирования анализатора"""

    analyzer = AgentNeedsAnalyzer()

    # Тестовые данные
    project_types = [
        "telegram-bot",
        "web-service",
        "ai-agent",
        "data-pipeline",
        "microservices"
    ]

    print("=" * 60)
    print("Agent Needs Analyzer - Тестирование")
    print("=" * 60)

    for project_type in project_types:
        print(f"\n{'=' * 60}")
        print(f"Project Type: {project_type}")
        print(f"{'=' * 60}")

        recommendations = analyzer.analyze(project_type)
        print(f"\n{analyzer.format_for_dialogue(recommendations)}")

        costs = analyzer.estimate_total_cost(recommendations)
        print(f"\n💰 Estimated cost:")
        print(f"   Required: {costs['required']} tokens/session")
        print(f"   Optional: {costs['optional']} tokens/session")
        print(f"   Total: {costs['total']} tokens/session")


if __name__ == "__main__":
    main()
