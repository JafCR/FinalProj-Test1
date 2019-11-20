pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
// added the experimental to try to return a struc in getAllUniversities

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/*
To use with Remix:
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Roles.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";
*/

contract ClassContract is Ownable {
    using Roles for Roles.Role; // We want to use the Roles library
    Roles.Role universityOwners; //Stores University owner Roles
    Roles.Role teachers; // Stores teacher Roles
    Roles.Role students; // Stores student Roles;


    uint public universityIdGenerator;

    mapping (uint => University) public universities; // Mapping to keep track of the Universities
    mapping (address => bool) studentFees; // Mapping to keep track if student has paid fees or not
    mapping (address => bool) grades;       // Mapping to keep track of studets' grades

    struct University {
        string name;
        string description;
        string website;
        string phoneNumber;
        bool open;
        uint memberIdGenerator;
        mapping (address => UniversityMember) owners;
        mapping (address => UniversityMember) teachers;
        mapping (address => UniversityMember) students;
    }

    struct UniversityInfo {
        string name;
        string description;
        string website;
        string phoneNumber;
        bool open;
    }

    struct UniversityMember {
        string fullName;
        string email;
        uint id;
        bool active;
    }

    // Events
    event LogUniversityAdded(string name, string desc, uint universityId);

    // Modifiers
    modifier validAddress(address _address) {
        require(_address != address(0), "ADDRESS CANNOT BE THE ZERO ADDRESS");
        _;
    }

    modifier ownerAtUniversity(uint universityId) {
        require((universities[universityId].owners[msg.sender].active == true), "DOES NOT BELONG TO THE UNIVERSITY OWNERS OR IS INACTIVE");
        require(universityOwners.has(msg.sender), "DOES NOT HAVE UNIVERSITY OWNER ROLE");
        _;
    }


    // Add Universities
    function addUniversity(string memory _name, string memory _description, string memory _website, string memory _phoneNumber)
    public onlyOwner
    returns (uint)
    {
        University memory newUniversity;
        newUniversity.name = _name;
        newUniversity.description = _description;
        newUniversity.website = _website;
        newUniversity.phoneNumber = _phoneNumber;
        newUniversity.open = true;
        universities[universityIdGenerator] = newUniversity;
        universityIdGenerator += 1;

        emit LogUniversityAdded(_name, _description, universityIdGenerator);
        return (universityIdGenerator - 1);
    }


    /*
    Roles and membership
    */

    function addUniversityOwnerRoles(address _ownerAddr, string memory _fullName, string memory _email, uint universityId)
    public onlyOwner
    validAddress(_ownerAddr)
    {
        universityOwners.add(_ownerAddr);

        UniversityMember memory newUniversityMember;
        newUniversityMember.fullName = _fullName;
        newUniversityMember.email = _email;
        newUniversityMember.id = universities[universityId].memberIdGenerator;
        universities[universityId].owners[_ownerAddr] = newUniversityMember;

        universities[universityId].memberIdGenerator += 1;
    }

    function addUniversityMember(address _addr, string memory _name, string memory _email, uint _universityId, string memory _memberRole) public
    validAddress(_addr)
    ownerAtUniversity(_universityId)
    returns (bool)
    {
        UniversityMember memory newUniversityMember;
        newUniversityMember.fullName = _name;
        newUniversityMember.email = _email;
        newUniversityMember.id = universities[_universityId].memberIdGenerator;
        universities[_universityId].memberIdGenerator += 1;

        if (keccak256(abi.encodePacked(_memberRole)) == keccak256(abi.encodePacked("teacher")))
        {
            teachers.add(_addr);
            universities[_universityId].teachers[_addr] = newUniversityMember;
        }
        else if (keccak256(abi.encodePacked(_memberRole)) == keccak256(abi.encodePacked("student")))
        {
            students.add(_addr);
            universities[_universityId].students[_addr] = newUniversityMember;
        }

        return true;
    }


    function getAllUniversities()
    public view
    returns (UniversityInfo[] memory)
    {
        UniversityInfo[] memory results = new UniversityInfo[](universityIdGenerator);
       for (uint i = 0; i < universityIdGenerator; i++) {
           results[i].name = universities[universityIdGenerator].name;
           results[i].description = universities[universityIdGenerator].description;
           results[i].website = universities[universityIdGenerator].website;
           results[i].phoneNumber = universities[universityIdGenerator].phoneNumber;
           results[i].open = universities[universityIdGenerator].open;
       }
       return results;
    }


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