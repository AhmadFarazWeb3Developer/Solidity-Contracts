const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
describe("To Do List", () => {
  const toDoListDeployment = async () => {
    const CONTRACT = await ethers.getContractFactory("toDoList");
    const deployed_contract = await CONTRACT.deploy("My first task");
    return { deployed_contract };
  };

  describe("Start", () => {
    beforeEach(async () => {
      ({ deployed_contract } = await loadFixture(toDoListDeployment));
    });

    it("Should create a task", async () => {
      await deployed_contract.createTask("My second task");
      console.log(await deployed_contract.getAllTask());
    });
  });
});
