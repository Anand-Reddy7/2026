from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import add_messages
from langgraph.graph import StateGraph, START
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.checkpoint.memory import InMemorySaver

from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage
from tools.kubernetes_tools import (
    get_nodes, 
    get_pods, 
    get_pod_logs, 
    get_events
    )

memory = InMemorySaver()

# State shared in LangGraph Nodes
class AgentState(TypedDict):
    messages: Annotated[list, add_messages]

# Create LLM
model = ChatOpenAI(
    model="gpt-5.4"
)

# Kubernetes tools available to the LLM
tools = [
    get_nodes,
    get_pods,
    get_pod_logs,
    get_events
]

model_with_tools = model.bind_tools(tools)

def llm_node(state: AgentState):
    response = model_with_tools.invoke(
        state["messages"]
    )

    return {
        "messages": [response]
    }

tool_node = ToolNode(tools)

graph_builder = StateGraph(AgentState)

graph_builder.add_node(
    "llm",
    llm_node
)

graph_builder.add_node(
    "tools",
    tool_node
)

graph_builder.add_edge(
    START,
    "llm"
)

graph_builder.add_conditional_edges(
    "llm",
    tools_condition
)

graph_builder.add_edge(
    "tools",
    "llm"
)

graph = graph_builder.compile(
    checkpointer=memory
)

config = {
    "configurable": {
        "thread_id": "k8s-incident-1"
    }
}

print(
    graph.get_graph().draw_ascii()
)


result = graph.invoke(
    {
        "messages": [
            HumanMessage(
                content=(
                    "list out all the pods in ai-agent-lab namespace of my kubernetes cluster"
                )
            )
        ]
    },
    config=config
)

print("\nFinal Answer:")
print(result["messages"][-1].content)

# # Second question - same thread_id
# result = graph.invoke(
#     {
#         "messages": [
#             HumanMessage(
#                 content="Why my pod in the failed state ?"
#             )
#         ]
#     },
#     config=config
# )

# print("\nSecond Answer:")
# print(result["messages"][-1].content)