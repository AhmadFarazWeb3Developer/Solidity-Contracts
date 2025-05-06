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
      expect(await deployed_contract.getAllTask()).to.have.lengthOf(2);
    });

    it("Should toggle task to complete(true)", async () => {
      await deployed_contract.toggleTaskStatus(0, true);
      await deployed_contract.toggleTaskStatus(1, true);
      const result = await deployed_contract.getAllTask();
      result.forEach((task) => {
        expect(task[2]).to.equal(true);
      });
    });
    it("Should get detail of specfic task", async () => {
      const result = await deployed_contract.getTaskDetails(0);
      expect(parseInt(result[0])).to.equal(0);
    });
  });
});
