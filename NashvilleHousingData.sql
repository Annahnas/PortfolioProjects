/*
Cleaning Data in SQL Queries
*/
Select *
From PortfolioProject..NashvilleHousingData
--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
select SaleDate
from PortfolioProject..NashvilleHousingData
--not used
select SaleDate, CONVERT(Date,SaleDate) 
from PortfolioProject..NashvilleHousingData
Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)
-- If it doesn't Update properly
ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;
--still not working
Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)
 --------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
Select *
From PortfolioProject.dbo.NashvilleHousingData
Where PropertyAddress is null
Select *
From PortfolioProject.dbo.NashvilleHousingData

--Where PropertyAddress is null
order by ParcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

--fill in the propertyAddress that are empty with the one with the same parcelID
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID
--error: Invalid length parameter passed to the LEFT or SUBSTRING function.
select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress) -1) as Address,
CHARINDEX(',',propertyAddress)
from PortfolioProject..NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousingData

--add a case 
SELECT 
    CASE 
        WHEN CHARINDEX(',', propertyAddress) > 0 THEN
            SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress) - 1)
        ELSE
            propertyAddress
    END as Address,
    CHARINDEX(',', propertyAddress) as CommaIndex
FROM PortfolioProject..NashvilleHousingData;

--separate address from city
SELECT
    CASE
        WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
            SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
        ELSE
            PropertyAddress
    END as StreetAddress,
    CASE
        WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
            SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
        ELSE
            ''
    END as Address
FROM PortfolioProject..NashvilleHousingData;

--for address
ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);
select * from PortfolioProject..NashvilleHousingData

--same error
Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--good
UPDATE NashvilleHousingData
SET PropertySplitAddress = 
    CASE
        WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
            SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
        ELSE
            PropertyAddress
    END;
    
--for city
ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Update NashvilleHousingData
--SET PropertySplitCity =
--CASE
        --WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
          --  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
       -- ELSE
         --   PropertyAddress
    --END;

Select *
From PortfolioProject..NashvilleHousingData

--split owner address : address,city and state
Select OwnerAddress
From PortfolioProject..NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousingData

--address
ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
--city
ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
--state
ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject..NashvilleHousingData
--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousingData
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From PortfolioProject..NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                    UniqueID
                    ) row_num
From NashvilleHousingData
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject..NashvilleHousingData
---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
Select *
From PortfolioProject..NashvilleHousingData
ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
