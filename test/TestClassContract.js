const ClassContract = artifacts.require("ClassContract");

contract("ClassContract", (accounts) =>{
    let classContract;
    let students;
    let teachers;

    beforeEach("Set up contract for each test", async () =>{

        students = [ accounts[1],
                    accounts[2],
                    accounts[3],
                    accounts[4]
        ];

        teachers = [ accounts[5],
                    accounts[6] ];
        classContract = await ClassContract.new();
        try {
            await classContract.addStudentRoles(students,{from:accounts[0]});
            await classContract.addTeacherRoles(teachers, {from:accounts[0]});
        } catch (e) {
            console.log("Error " + e)
        }

    });


    it('ensure that owner is the first address', async  () => {
        const owner = await classContract.owner();
        assert.equal(owner, accounts[0]);

    });

    it('student should be able to pay fees >= 4 ether', async () => {

        try {
            await classContract.payFees({from:students[0], value:web3.utils.toWei("4","ether")})
        } catch (e) {
            console.log(`Error: ${e}`);
        }

        let hasPaidFees = await classContract.hasPaidFees.call(students[0]);
        assert.equal(hasPaidFees, true,"Student has not paid fees");

    });


    it('teacher should be able to grade the student who pays fees', async () => {
        let studentWasGraded;
        try {
            await classContract.gradeStudent(students[0],true,{from:teachers[0]});
            studentWasGraded = true;
        }catch (e) {
            studentWasGraded = false;
        }

        assert.equal(studentWasGraded, true, "Student was not graded")
    });


    it('student should not be able to grade another student', async () => {
        let studentWasGraded;

        await classContract.payFees({from:students[1], value:web3.utils.toWei("4","ether")})

        try {
            await classContract.gradeStudent(students[1],false,{from:students[0]});
            studentWasGraded = true;
        } catch (e) {
            studentWasGraded = false;
            console.log(e)
        }

        assert.equal(false,studentWasGraded,"Student graded another student successfully")

    });


    it('teacher should not pay fees', async () =>{

        let teacherPaidFees;
        try {
            await classContract.payFees({from:teachers[0], value:web3.utils.toWei("4","ether")})
            teacherPaidFees = true;
        } catch (e) {
            teacherPaidFees = false;
            console.log(e);
        }

        assert.isFalse(teacherPaidFees,"Teacher was able to pay fees");
    });


    it('owner can terminate contract', async ()=> {
        let classTerminated;
        try {
            await classContract.terminateClass({from:accounts[0]})
            classTerminated = true;
        } catch (e) {
            console.log(e);
            classTerminated = false;
        }

        assert.isTrue(classTerminated)

    });


});