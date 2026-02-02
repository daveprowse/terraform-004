# AWS Pricing Information

Remember that AWS (and other cloud providers) will charge you for using their service. How much depends on several factors. Read on and be informed!

---

## From the Amazon Website (Updated 2025) 

https://aws.amazon.com/free/free-tier-faqs/ 

> Quote: "The AWS Free Tier applies to participating services across our global regions. Your free usage under the AWS Free Tier is calculated each month across all regions and automatically applied to your bill. For example, you will receive 750 Amazon EC2 Linux Micro Instance hours for free across all of the regions you use, not 750 hours per region. Unused monthly usage will not roll over to future months. The AWS Free Tier is now available in China (ZHY) and China (BJS) regions as well. The AWS Free Tier is not available in the AWS GovCloud (US) regions, with the exception of Lambda for AWS GovCloud (US)."


‼️ **IMPORTANT** ‼️ Free Tier qualifying instances have changed as of July 15th, 2025. If you created your AWS account before that date then you can use t2.micro instances as part of the free tier and potentially t3.micro. If you created your AWS account after July 15th, 2025, you should use t3.micro instances as part of the free tier, and not t2.micro. For those of you in the second group, change any t2.micro instance types to t3.micro!!

However, this will all depend on your region. And remember, availability and pricing is subject to change. Always check and use Free Tier when available!

## Links and Info

**Pricing on demand:**

https://aws.amazon.com/ec2/pricing/on-demand/ 

Try typing in **t2.micro** in the search field. (For example, the cost in Dec, 2025 was $.0116 cents per hour.)

**Free Tier eligible examples:**

https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#AMICatalog

(search for Debian, Ubuntu, EC2, and other free tier examples...) 

> Note: Depending on your account (and region), Free Tier may include: t2.micro, t3.micro, t4g.micro, and flex instances. (But this could change at any time!)

**AWS calculator:**  https://calculator.aws 

- Cost for a t2.micro is .0116 cents per hour (about $100 per year) (Dec, 2025)
- Cost for a t4g.nano is .0042 cents per hour (about $37 per year) (Dec, 2025)

**AWS cost explorer** (for currently running infrastructure)

https://aws.amazon.com/aws-cost-management/aws-cost-explorer/ 

## More AWS Free Tier Information

For more information, see the following links:
> - [EC2 Free Tier Comparison Table](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html)
> - [AWS Free Tier Plan Selection (General Overview)](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-plans.html)
> - [AWS Free Tier Overview (Main Documentation)](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier.html)
> - [AWS Free Tier FAQs (Official Q&A)](https://aws.amazon.com/free/free-tier-faqs/)
> - [Tracking Free Tier Usage (Monitoring)](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/tracking-free-tier-usage.html)

---

**Third-party** - AWS Pricing module:

https://github.com/terraform-aws-modules/terraform-aws-pricing 




