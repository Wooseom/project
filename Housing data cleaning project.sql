#<cleaning data> 
SELECT *
FROM Nashville
#---------------------------------------------------------------------------------------------------------------------

#Standardize date format
SELECT SaleDate, Date(SaleDate)
FROM Nashville
 
#SET SQL_SAFE_UPDATES=0; -> run to disable safe update mode

ALTER TABLE Nashville
ADD SaleDateConverted Date;

Update Nashville
SET SaleDateConverted = Date(SaleDate);

SELECT SaleDateConverted, Date(SaleDate)
FROM Nashville

#<populate property address data>-----------------------------------------------------------------------------------------------------
SELECT *
FROM Nashville
order by ParcelID

#joining duplicated parcelId in same propertyAddress where a.propertyAddress is null
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress
FROM Nashville a 
JOIN Nashville b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

#Modifying a.propertyaddress as combined propertyaddress(joined table) 
UPDATE Nashville a 
JOIN Nashville b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

#<Breaking out propertyaddress into city, state, and address>
SELECT PropertyAddress
FROM Nashville #where propertyaddress is null order by parcelID

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress)) as Address
#Extracting all substring of propertyaddress after the first comma
FROM Nashville;

ALTER TABLE Nashville
ADD PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1)

ALTER TABLE Nashville
ADD PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress))

SELECT OwnerAddress
FROM Nashville

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address1, #extracting substring before the first comma
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Address2, #between first and second comma
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS Address3 #between second and third comma
FROM Nashville;

ALTER TABLE Nashville
ADD OwnerSplitAddress Nvarchar(255);

Update Nashville
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1) 

ALTER TABLE Nashville
ADD OwnerSplitCity Nvarchar(255);

Update Nashville
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) 

ALTER TABLE Nashville
ADD OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) 

SELECT *
FROM Nashville
#----------------------------------------------------------------------------------------------------------
#<Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant ='N' THEN 'No'
      ELSE SoldAsVacant
      END AS  YesOrNo
FROM Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant ='N' THEN 'No'
      ELSE SoldAsVacant
      END 
#-----------------------------------------------------------------------------------
#Removing Duplicates
WITH RowNumCTE AS (
  SELECT *, 
    ROW_NUMBER() OVER(
      PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
      ORDER BY UniqueID
    ) row_num
  FROM Nashville 
)
DELETE FROM Nashville
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID) IN (
  SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID
  FROM RowNumCTE
  WHERE row_num > 1
);
#ORDER BY PropertyAddress

WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
      ORDER BY UniqueID
    ) row_num
  FROM Nashville
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


#--------------------------------------------------------------------------------
#<Delete unused Columns>

ALTER TABLE Nashville
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;
DROP COLUMN SaleDate;


SELECT *
FROM Nashville


