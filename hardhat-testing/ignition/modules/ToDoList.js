const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const ToDoListContractDeployed = buildModule("ToDoList", (m) => {
  const initialTaskContent = m.getParameter(
    "_initialTaskContent",
    "My First Task"
  );

  const deployed_contract = m.contract("toDoList", [initialTaskContent]); // Pass parameter in constructor

  return { deployed_contract };
});

module.exports = ToDoListContractDeployed;
