// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.28;
pragma solidity ^0.8.19;

contract toDoList {
    struct Task {
        uint256 id;
        string content;
        bool completed;
    }

    mapping(uint256 => Task) public tasks;

    uint256 taskCount = 0;
    event Debug(string conent);

    constructor(string memory _initialTaskContent) {
        tasks[taskCount] = Task({
            id: taskCount,
            content: _initialTaskContent,
            completed: false
        });
        emit TaskCreated(taskCount, _initialTaskContent, false);
        taskCount++;
    }

    function createTask(string memory _content) public {
        tasks[taskCount] = Task(taskCount, _content, false);
        emit TaskCreated(taskCount, _content, false);

        taskCount++;
    }

    function toggleTaskStatus(uint256 _taskId, bool _status) public {
        tasks[_taskId].completed = _status;
        emit TaskStatusUpdated(_taskId, _status);
    }

    function getTaskDetails(uint256 _taskId) public view returns (Task memory) {
        return tasks[_taskId];
    }

    function getAllTask() public view returns (Task[] memory) {
        Task[] memory allTasks = new Task[](taskCount);

        for (uint256 i = 0; i < allTasks.length; i++) {
            allTasks[i] = tasks[i];
        }
        return allTasks;
    }

    event TaskCreated(uint256 indexed taskCount, string content, bool status);
    event TaskStatusUpdated(uint256 indexed taskId, bool status);
}
