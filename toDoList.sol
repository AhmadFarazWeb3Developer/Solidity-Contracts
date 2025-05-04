// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract toDoList {
    struct Task {
        uint256 id;
        string content;
        bool completed;
    }

    mapping(uint256 => Task) public tasks;

    uint taskCount = 0;

    constructor(string memory _initalTaskContent) {
        Task(0, _initalTask, false);
        taskCount++;
    }

    function createTask(string memory _content) public {
        Task(taskCount, _content, false);
        emit TaskCreated(taskCount, _content, false);
        taskCount++;
    }

    function toggleTaskCompleted(uint256 _taskId, bool _status) public {}

    event TaskCreated(uint indexed taskCount, string content, bool status);
}

// Define a function toggleTaskCompleted that takes a uint parameter _id and toggles the completion status of the task with the given ID. This function should:
// Retrieve the task from the tasks mapping.
// Toggle the completed status of the task.
// Update the task in the tasks mapping.
// Emit the TaskCompleted event.
// Define a function getTask that takes a uint parameter _id and returns the details of the task with the given ID. The function should return:
// uint: The task ID.
// string: The task content.
// bool: The task completion status.
// Define a function getTaskCount that returns the total number of tasks.
// 12345678
// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.19;

// contract demo {

// }

// Run Tests
