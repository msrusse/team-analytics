ALTER PROCEDURE election_result_data @StateAbbrev CHAR(2), @CountyName VARCHAR(35), @CandidateFirstName VARCHAR(25), @CandidateLastName VARCHAR(35), @CandidateParty VARCHAR(7), @VoteCount INT
AS

DECLARE @CandidateID INT
DECLARE @ActualFIPS CHAR(5)
DECLARE @Won BIT
DECLARE @PartyID INT

SET @PartyID = (SELECT partyID FROM party WHERE partyAbbrev = @CandidateParty)

IF @CandidateFirstName NOT IN (SELECT firstName FROM candidate WHERE lastName = @CandidateLastName)
    INSERT INTO candidate (
        firstName,
        lastName,
        partyID
    ) VALUES (
        @CandidateFirstName,
        @CandidateLastName,
        @PartyID
    )

SET @CandidateID = (SELECT candidateID FROM candidate
                        WHERE lastName = @CandidateLastName 
                        AND firstName = @CandidateFirstName)

SET @ActualFIPS = (SELECT FIPSCode FROM countyInfo 
                    WHERE countyName = @CountyName 
                    AND stateAbbrev = @StateAbbrev)

SET @Won = 0

IF @VoteCount >= (SELECT MAX(totalVotes) FROM electionResult
                    WHERE FIPSCode = @ActualFIPS)
    SET @Won = 1

UPDATE electionResult
SET won = 0
WHERE FIPSCode = @ActualFIPS
AND totalVotes < @VoteCount

IF @CandidateID IN (SELECT candidateID FROM electionResult WHERE FIPSCode = @ActualFIPS)
    UPDATE electionResult
    SET totalVotes = @VoteCount,
        won = @Won
    WHERE candidateID = @CandidateID
    AND FIPSCode = @ActualFIPS
ELSE
    INSERT INTO electionResult VALUES (
        @ActualFIPS,
        @CandidateID,
        @VoteCount,
        @Won
    )