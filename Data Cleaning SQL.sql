/********** Data Cleaning ***********/

--Modify Data Types
SELECT SaleDate
FROM [Covid Analysis].[dbo].[NashvilleHousing]

ALTER TABLE [Covid Analysis].[dbo].[NashvilleHousing]
ADD SaleDateConverted Date;

Update [Covid Analysis].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM [Covid Analysis].[dbo].[NashvilleHousing]

---------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data 

--same PraceID and same PropertyAddress but not same UniqueID
SELECT *
FROM [Covid Analysis].[dbo].[NashvilleHousing]
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress,a.ParcelID ,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Covid Analysis].[dbo].[NashvilleHousing] a
JOIN [Covid Analysis].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] --NOT the Same ROW
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Covid Analysis].[dbo].[NashvilleHousing] a
JOIN [Covid Analysis].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] --NOT the Same ROW
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)
SELECT SUBSTRING(PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM [Covid Analysis]..[NashvilleHousing]
ORDER BY ParcelID

ALTER TABLE [Covid Analysis]..[NashvilleHousing]
ADD PropertySplitAddress NVARCHAR (255);

Update [Covid Analysis]..[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Covid Analysis]..[NashvilleHousing]
ADD PropertySplitCity NVARCHAR (255);

Update [Covid Analysis]..[NashvilleHousing]
SET PropertySplitCity = SUBSTRING (PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM [Covid Analysis]..NashvilleHousing


SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'), 1) AS State,
PARSENAME (REPLACE(OwnerAddress,',','.'), 2) AS City ,
PARSENAME (REPLACE(OwnerAddress,',','.'), 3) AS Address
FROM [Covid Analysis]..NashvilleHousing



ALTER TABLE [Covid Analysis]..[NashvilleHousing]
ADD OwnerSplitAddress NVARCHAR (255);

Update [Covid Analysis]..[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [Covid Analysis]..[NashvilleHousing]
ADD OwnerSplitCity NVARCHAR (255);

Update [Covid Analysis]..[NashvilleHousing]
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Covid Analysis]..[NashvilleHousing]
ADD OwnerSplitState NVARCHAR (255);

Update [Covid Analysis]..[NashvilleHousing]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM [Covid Analysis]..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------
-- Chanege Y and N in SoldAsVacant
SELECT DISTINCT (SoldAsVacant) , COUNT(SoldAsVacant)
FROM [Covid Analysis]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)


SELECT SoldAsVacant
,CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM [Covid Analysis]..NashvilleHousing

UPDATE [Covid Analysis]..NashvilleHousing
SET SoldAsVacant=CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


SELECT DISTINCT (SoldAsVacant)
FROM [Covid Analysis]..NashvilleHousing	


---------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

-- WITH is a temporary data
--Row_Number Sequential number to each row 
WITH RowNum 
AS
(SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID
					) RowNum
FROM [Covid Analysis]..NashvilleHousing	)

--SELECT *
DELETE
FROM RowNum
WHERE RowNum > 1
--ORDER BY PropertyAddress



---------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
SELECT *
FROM [Covid Analysis]..NashvilleHousing

ALTER TABLE [Covid Analysis]..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
