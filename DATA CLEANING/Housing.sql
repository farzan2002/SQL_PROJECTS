USE housing_project;
SELECT * FROM housing;



--1]CONVERTING THE DATA TYPE IN 'SaleDate' COLUMN FROM DATETIME TO DATE

ALTER TABLE housing
ALTER COLUMN SaleDate DATE;




--2]POPULATING PROPERTY ADDRESS DATA

	--SHOWCASES ALL THE NULL ROWS WHICH HAS SAME 'ParcelID' BUT DIFFERENT 'UniqueID' BETWEEN THE TWO COLUMNS

	SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
	FROM housing AS a 
	join 
	housing AS b
	ON 
		a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
	WHERE 
		a.PropertyAddress IS NULL;



	--UPDATING THE NULL VALUES 

	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM housing AS a 
	join 
	housing AS b
	ON 
		a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
	WHERE 
		a.PropertyAddress is null;







--3]SPLITTING THE VALUES IN 'PropertyAddress' INTO ADDRESS, CITY



	----SHOWCASING THE SPLIT VALUES
	SELECT  
	SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
	FROM housing;



	----ADDING COLUMNS 'Address' & 'City' AND UPDATING THEM WITH THE SPLIT VALUES 
	ALTER TABLE housing 
	ADD
		Prop_Address nvarchar(255);

	UPDATE housing
	SET
		Prop_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


	ALTER TABLE housing 
	ADD
		Prop_City nvarchar(255);

	UPDATE housing
	SET
		Prop_City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));






--4]SPLITTING THE VALUES IN 'OwnerAddress' INTO ADDRESS, CITY, STATE


	----SHOWCASING THE SPLIT VALUES
	SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
	FROM housing;




	----ADDING COLUMNS 'Address', 'City' & 'State' AND UPDATING THEM WITH THE SPLIT VALUES 
	ALTER TABLE housing 
		ADD
			Owner_Address nvarchar(255);

	ALTER TABLE housing 
		ADD
			Owner_City nvarchar(255);

	ALTER TABLE housing 
		ADD
			Owner_State nvarchar(255);

	
	UPDATE housing
		SET
			Owner_Address =PARSENAME(REPLACE(OwnerAddress,',','.'),3);


	UPDATE housing
		SET
			Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

	
	UPDATE housing
		SET
			Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1);





--5]UPDATE THE 'Y' & 'N' VALUES IN THE COLUMN "SoldAsVacant" TO 'YES' AND 'NO'

	----SHOWCASING THE 'Y' & 'N' AS 'Yes' & 'No'
	SELECT SoldAsVacant,
		CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END
	FROM housing;

	
	----UPDATING THE VALUES TO 'YES' & 'NO'
	UPDATE housing
	SET SoldAsVacant = 
		CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END
	FROM housing;


--6] REMOVING DUPLICATES

	----SHOWCASING THE DUPLICATE VALUES 

	SELECT ParcelID, SaleDate, LegalReference, COUNT(*) AS DuplicateCount
	FROM housing
	GROUP BY ParcelID, SaleDate, LegalReference
	HAVING COUNT(*) > 1;


	----DELETING THE DUPLICATE VALUES
	
	DELETE FROM housing
	WHERE [UniqueID ] NOT IN (
		SELECT MIN([UniqueID ])
		FROM housing
		GROUP BY ParcelID, SaleDate, LegalReference
	);






--7]DELETING UNUSED COLUMNS

ALTER TABLE housing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict;







