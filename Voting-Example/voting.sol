// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

contract Ballot{

    struct Voter{
        uint id;
        bool voted;
        address delegate;
        bool right;
        uint weight;
    }

    struct Candidate{
        string name;
        uint votes;
    }

    address ChairPerson;


    mapping(address => Voter) public voters;
    uint votersNums = 0;

    Candidate[] public candidates;

    uint[] public winner;

    constructor(string[] memory candidateNames)
    {
        ChairPerson = msg.sender;


        for (uint i = 0; i < candidateNames.length; i++) 
        {
            candidates.push(
                Candidate({
                    name: candidateNames[i],
                    votes: 0
                })
            );
        }

    }

    function giveRighttoVote(address _voter)  external
    {
        require(msg.sender == ChairPerson, "Only ChairPerson can give Vote.");

        require(!voters[_voter].voted,"You have already voted.");

        require(!voters[_voter].right,"You already have been granted the Right to vote.");

        voters[_voter].right = true;

        voters[_voter].weight = 1;

        votersNums += 1;

        voters[_voter].id = votersNums;
    }

    function delegate(address to) external
    {
        
        require(voters[msg.sender].right, "No Right to Vote.");

        require(!voters[msg.sender].voted,"You have Already Voted");

        require(to != msg.sender, "Self-delegation is disallowed.");

        require(voters[to].id > 0,"No such Voter Exists.");

        require(voters[to].right,"Delegate Person have No right to Vote.");

        require(!voters[to].voted,"Delegate Person have already Voted.");

        voters[to].weight += 1;

        voters[msg.sender].voted = true;

    }

    function giveVote(uint _option) external
    {
        address _voter = msg.sender;

        require(!voters[_voter].voted,"You have already voted.");

        require(voters[_voter].right,"No Right to Vote.");

        candidates[_option].votes += voters[_voter].weight;

        voters[_voter].voted = true;
        
    }

    function selectWinner() external returns (string memory)
    {
        require(msg.sender == ChairPerson,"You are not ChairPerson.");
    
        uint max = 0;

        for (uint i = 0; i < candidates.length; i++) 
        {
            if (candidates[i].votes > max ) {
                delete winner;
                winner.push(i);
                max = candidates[i].votes;
            } else if (candidates[i].votes == max) {
                winner.push(i);
            }
        }

        if(winner.length == 1)
        {
            return candidates[winner[0]].name;
        }
        else
        {
            string memory all;

            for (uint i = 0; i< winner.length; i++) 
            {
                all = string(abi.encodePacked(all, " ", candidates[winner[i]].name));
            }
            return all;
        }
    }

}
