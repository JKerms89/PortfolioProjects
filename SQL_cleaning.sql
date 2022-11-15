-- Cleaning data in SQL queries

Select *
From PortfolioProject..[dbo.NashvilleHousing]

-- Standardise Date Format

ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
ADD SaleDateConverted Date;

UPDATE PortfolioProject..[dbo.NashvilleHousing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From PortfolioProject..[dbo.NashvilleHousing]

ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject..[dbo.NashvilleHousing]


-- Populate Property Address data
-- Not to self: Recap on self-joins 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[dbo.NashvilleHousing] a
JOIN PortfolioProject..[dbo.NashvilleHousing] b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[dbo.NashvilleHousing] a
JOIN PortfolioProject..[dbo.NashvilleHousing] b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..[dbo.NashvilleHousing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As Address
FROM PortfolioProject..[dbo.NashvilleHousing]

ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..[dbo.NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject..[dbo.NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..[dbo.NashvilleHousing]


--------------------------------------------------------------------------------------------------------------------
SELECT OwnerAddress
FROM PortfolioProject..[dbo.NashvilleHousing]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..[dbo.NashvilleHousing]

ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..[dbo.NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..[dbo.NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..[dbo.NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject..[dbo.NashvilleHousing]

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[dbo.NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..[dbo.NashvilleHousing]

UPDATE PortfolioProject..[dbo.NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[dbo.NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject..[dbo.NashvilleHousing]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject..[dbo.NashvilleHousing]
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..[dbo.NashvilleHousing]


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
