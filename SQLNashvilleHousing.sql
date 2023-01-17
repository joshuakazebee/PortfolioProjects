-- Cleaning the Data

SELECT *
FROM PortfolioProjects..NashvilleHousing

-- Standardize Date Format

SELECT saledateconverted, CONVERT(date, saledate)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD saledateconverted Date;

UPDATE NashvilleHousing
SET saledateconverted = CONVERT(date, saledate)

-- Populate Property Address Data (Note to self, I don't fully understand how joining a table on itself helped to populate empty addresses)

SELECT *
FROM PortfolioProjects..NashvilleHousing
--WHERE propertyaddress is null
ORDER BY parcelID

SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.UniqueID != b.UniqueID
WHERE a.propertyaddress is null

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.UniqueID != b.UniqueID
WHERE a.propertyaddress is null

-- Breaking out Address Into Indivisual Columns

SELECT propertyaddress
FROM PortfolioProjects..NashvilleHousing

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) as Address
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Varchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Varchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))


SELECT
PARSENAME(REPLACE(owneraddress, ',', '.'), 3)
, PARSENAME(REPLACE(owneraddress, ',', '.'), 2)
, PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT soldasvacant
, CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	   WHEN soldasvacant = 'N' THEN 'No'
	   ELSE soldasvacant
	   END
FROM PortfolioProjects..NashvilleHousing

UPDATE PortfolioProjects..NashvilleHousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	   WHEN soldasvacant = 'N' THEN 'No'
	   ELSE soldasvacant
	   END

-- Remove Duplicates

WITH RowNumCTE as(
SELECT *
, ROW_NUMBER() OVER(
	PARTITION BY parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
	ORDER BY uniqueID
	) row_num
FROM PortfolioProjects..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

SELECT *
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN saledate

