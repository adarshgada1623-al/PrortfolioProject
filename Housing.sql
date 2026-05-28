SELECT * FROM nashvillehousing;

UPDATE NashvilleHousing
SET PropertyAddress = NULL
WHERE TRIM(PropertyAddress) = '';

-- Populate Propeerty Address Data

SELECT * FROM nashvillehousing
WHERE PropertyAddress IS NULL AND ParcelID IN (

SELECT ParcelID FROM nashvillehousing
GROUP BY ParcelID
HAVING COUNT(*)>1 );

SELECT A. ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress 
FROM nashvillehousing A
JOIN nashvillehousing B
	ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

UPDATE nashvillehousing A
JOIN nashvillehousing B
	ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
SET A.PropertyAddress = B.PropertyAddress
WHERE A.PropertyAddress IS NULL;

-- Breaking Out Adderess into Individual Columns (Address,City,State)
SELECT 
SUBSTRING(PropertyAddress,1, LOCATE(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress)) AS Address
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, LOCATE(',',PropertyAddress)-1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT * 
FROM nashvillehousing;

SELECT
TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS StreetAddress,

TRIM(
    SUBSTRING_INDEX(
        SUBSTRING_INDEX(OwnerAddress, ',', 2),
    ',', -1)
) AS City,
TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS State
FROM NashvilleHousing;

ALTER TABLE nashvillehousing
ADD OwenerStreetAddress VARCHAR(255);

UPDATE nashvillehousing
SET OwenerStreetAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

ALTER TABLE nashvillehousing
ADD OwenerSplitCity VARCHAR(255);

UPDATE nashvillehousing
SET OwenerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',', -1)) ;

ALTER TABLE nashvillehousing
ADD OwenerSplitState VARCHAR(255);

UPDATE nashvillehousing
SET OwenerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

-- Change Y AND N Yes AND No IN "SoldAsVacant" field
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2 ;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END 
FROM nashvillehousing ; 

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END ;

-- Remove Duplicates
WITH ROW_NUMCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
        PropertyAddress,
        SalePrice,
        SaleDate,
		LegalReference
        ORDER BY
        UniqueID
        ) row_num
FROM nashvillehousing
)
SELECT *
FROM ROW_NUMCTE
WHERE row_num > 1;

DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER(
                PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
				 LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM NashvilleHousing
    ) AS duplicates
    WHERE row_num > 1
);

-- DELETE UNUSED COLUMN
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict;

SELECT * FROM nashvillehousing;

















