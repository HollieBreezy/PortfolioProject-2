/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM NashvilleHousing



-- STANDARDIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM NashvilleHousing

UPDATE NashvilleHousing                   --DIDN'T WORK
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing              --HAD TO USE THIS
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



--POPULATE PROPERTY ADRESS DATA

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing             
ADD PropertySplitAddress Nvarchar (255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing              
ADD PropertySplitCity Nvarchar (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




SELECT OwnerAddress
FROM NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing
WHERE PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) IS NOT NULL


ALTER TABLE NashvilleHousing              
ADD OwnerSplitAddress Nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing              
ADD OwnerSplitCity Nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing              
ADD OwnerSplitState Nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


--CHANGE Y TAND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant 
ORDER BY 2


SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant 
	 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                       WHEN SoldAsVacant = 'N' THEN 'NO'
	                   ELSE SoldAsVacant 
	                   END


--REMOVE DUPLICATE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing


--DELETE UNUSED COLUMN

SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate