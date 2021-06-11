/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  --Cleaning Data in SQL quesries

  Select *
  From PortfolioProject.dbo.NashvilleHousing

  --Standardize Date Formate
  
  Select SaleDateConverted, CONVERT(Date, SaleDate)
  From PortfolioProject.dbo.NashvilleHousing

 Update NashvilleHousing
 SET SaleDate = CONVERT(Date, SaleDate)
 
 ALTER Table NashvilleHousing
 Add SaleDateConverted Date;
 
 Update NashvilleHousing
 SET SaleDateConverted = CONVERT(Date, SaleDate)

 --Populate Property Address Data

 Select *
 From PortfolioProject.dbo.NashvilleHousing
 --Where PropertyAddress is null
 Order by ParcelID


 Select a.ParcelID, a.PropertyAddress, b. ParcelID, b. PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null

 UPDATE a
 SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into individual columns ( Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
 Add PropertySplitAddress NVARCHAR(255);
 
 Update NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

 ALTER Table NashvilleHousing
 Add PropertySplitCity NVARCHAR(255);
 
 Update NashvilleHousing
 SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 SELECT *
 From PortfolioProject.dbo.NashvilleHousing

--Owner Address
 SELECT OwnerAddress
 From PortfolioProject.dbo.NashvilleHousing
 
 SELECT
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as Address
 , PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City
 , PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State
 From PortfolioProject.dbo.NashvilleHousing

 ALTER Table NashvilleHousing
 Add OwnerSplitAddress NVARCHAR(255);
 
 Update NashvilleHousing
 SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

 ALTER Table NashvilleHousing
 Add OwnerSplitCity NVARCHAR(255);
 
 Update NashvilleHousing
 SET OwnerSplitCity=  PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

 ALTER Table NashvilleHousing
 Add OwnerSplitState NVARCHAR(255);
 
 Update NashvilleHousing
 SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

 SELECT *
 From PortfolioProject.dbo.NashvilleHousing

 -- Change Y and N to Yes and No in 'Sold as Vacant' field

 SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
 From PortfolioProject.dbo.NashvilleHousing
 Group by SoldAsVacant
 Order by 2

 SELECT SoldAsVacant
 , CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
 From PortfolioProject.dbo.NashvilleHousing

 Update NashvilleHousing
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Remove Duplicate
WITH RowNumCTE AS(
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
 From PortfolioProject.dbo.NashvilleHousing
 --ORDER BY ParcelID
 )
SELECT *
 From RowNumCTE
 Where row_num > 1
 ORDER BY PropertyAddress




 