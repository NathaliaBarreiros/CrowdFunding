// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    enum FundRaisingState { Opened, Closed }

    struct Contribution {
        address contributor;
        uint value;
    }

    struct Project {
        string id;
        string name;
        string description;
        address payable author;
        FundRaisingState state;
        uint256 funds;
        uint256 fundraisingGoal;
    }

    Project[] public projects;
    mapping ( string => Contribution[]) public contributions;

    event ProjectCreated(
        string projectId,
        string name,
        string description,
        uint256 fundraisingGoal
    );

    event ProjectFunded(
        string projectId,
        uint256 value
    );

    event ProjectStateChanged (
        string id,
        FundRaisingState state 
    );

    //constructor(string memory _id, string memory _name, string memory _description, uint _fundraisingGoal) {
    //    project = Project(_id, _name, _description, payable(msg.sender), FundRaisingState.Opened, 0, _fundraisingGoal);
    //}

    modifier isAuthor(uint256 projectIndex) {
        require(projects[projectIndex].author == msg.sender, "You need to be the project author");
        _;
    }

    modifier isNotAuthor(uint256 projectIndex) {
        require(projects[projectIndex].author != msg.sender, "As author, you can not fund your own project");
        _;
    }

    function createProject(string calldata id, string calldata name, string calldata description, uint256 fundraisingGoal) public {
        require(fundraisingGoal > 0, 'fundraising goal must be greater than 0');
        //creo variable que inicializa el proyecto
        Project memory project = Project(id, name, description, payable(msg.sender), FundRaisingState.Opened, 0, fundraisingGoal);
        //agrego esta variable al array de proyectos
        projects.push(project);
        emit ProjectCreated(id, name, description, fundraisingGoal);
    }

    function fundProject(uint projectIndex) public payable isNotAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != FundRaisingState.Closed, 'The project can not receive funds');
        require(msg.value > 0, 'Fund value must be greater than 0');
        project.author.transfer(msg.value);
        project.funds += msg.value;
        projects[projectIndex] = project;

        contributions[project.id].push(Contribution(msg.sender, msg.value));

        emit ProjectFunded(project.id, msg.value);
    }

    function changeProjectState(FundRaisingState newState, uint256 projectIndex) public isAuthor(projectIndex){
        Project memory project = projects[projectIndex];
        require(project.state != newState, 'New state must be different');
        project.state = newState;
        projects[projectIndex] = project;
        emit ProjectStateChanged(project.id, newState);
    }

}