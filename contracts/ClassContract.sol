pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ClassContract is Ownable {
    using Roles for Roles.Role; // We want to use the Roles library
    Roles.Role teachers; // Stores teacher Roles
    Roles.Role students; // Stores student Roles;
    mapping (address => bool) studentFees; // This mapping keeps tract if student has paid fees or not
    mapping (address => bool) grades;       // Keeps tract of studets' grades


    function addTeacherRoles(address[] memory _teachers) public onlyOwner {
        for(uint i = 0; i < _teachers.length; i++)
        {
            teachers.add(_teachers[i]);
        }
    }

    function addStudentRoles(address[] memory _students) public onlyOwner
    {
        for(uint j = 0; j < _students.length; j++)
        {
            students.add(_students[j]);
        }
    }

    function areFeesEnough(uint amount) external pure returns (bool)
    {
        return amount >= 4 ether;

    }

    function payFees() public payable {
        require(students.has(msg.sender), "DOES NOT HAVE STUDENT ROLE");
        if(this.areFeesEnough(msg.value))
        {
            address(uint160(owner())).transfer(msg.value); // Cast to address(uint160) to make address payable
            studentFees[msg.sender] = true;
        }

    }

    function gradeStudent(address student, bool grade) public
    {
        require(teachers.has(msg.sender), "DOES NOT HAVE TEACHER ROLE");
        require(students.has(student), "ADDRESS PROVIDED IS NOT A STUDENT");
        grades[student] = grade;
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "ADDRESS CANNOT BE THE ZERO ADDRESS");
        _;
    }


    function hasPaidFees(address account) validAddress(account) public view returns (bool) {
        require(students.has(account),"Provided account is not a student");
        return studentFees[account];
    }


    function terminateClass() onlyOwner public {
        selfdestruct(msg.sender);
    }


    function getBalance(address account) public view returns (uint) {
        return account.balance;
    }

}